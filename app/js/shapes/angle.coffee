$ -> $.shape "angle",
  numberOfPoints: 3
  raphaelType: "path"
  textPadding:
    x: 10
    y: 5
  options:
    offset: 30


  _create: (ui) ->
    @unit="mm"
    @_addNthPoint(@points.length, ui)


  # create the first point and then display the line while positioning the second
  _addNthPoint: (n, ui = true) ->
    if n < 3 then @_addPoint().$node.one "aftercreate", => @_addNthPoint(@points.length)

    if n >= 2 and @_text? == false then @_initText()

    # there is no point with index 2, finish the line creation
    @_afterCreate() if ui == true and n == 3


  _zoomChange: (e) ->
    @render()
    return true


  _initText: ->
    @_text = @sketch.text
      type: "implicit"
      text: "0"
      serialize: false
    @_text.$node.hide().addClass("dimension-text").bind("editstart", @_editTextStart)
    @_text.parent = this
    @_initElement()
    @_text.$node.show().bind("textdrag", @_dragText)
    @sketch.$svg.bind "zoomchange", @_zoomChange


  _attrs: ->
    base = @points[0].$v
    tangents = [@points[1].$v.subtract(base), @points[2].$v.subtract(base)]
    r = Math.min tangents[0].modulus(), tangents[1].modulus()
    console.log r
    r /= 2.3
    r = Math.min r, 30*@sketch._zoom.positionMultiplier
    arcPoints = (base.add(tg.toUnitVector().x(r)) for tg in tangents)
    console.log tangents, arcPoints
    path = "M#{arcPoints[0].toPath()} "
    path +="A#{r},#{r}, 0, 0, 0, #{arcPoints[1].toPath()}"
    return path: path

    


  # dragging the dimension's text has the same effect as dragging the dimension's lines
  _dragText: (e, $vMouse) -> @_dragElement(e, $vMouse)


  _updateVariables: ->
    # TODO: share this code with the attrs method better
    @_$vTangent = @points[1].$v.subtract(@points[0].$v)
    @_$vUnitTangent = @_$vTangent.toUnitVector()
    #hack to prevent even odder behaviour when we have zero length dimensions
    @_$vUnitTangent.elements[0] = 1 if @_$vUnitTangent.distanceFrom(Vector.Zero(2)) == 0
    @_$vNormal = $V [ -@_$vUnitTangent.elements[1], @_$vUnitTangent.elements[0] ]

    @_$l = $L(@points[0].$v, @points[1].$v.subtract(@points[0].$v))


  # Update the dimension's measurement graphic offset to the distance from the line
  # between the two points to the mouse vector.
  _dragElement: (e, $vMouse) ->
    @_updateVariables()

    # calculating the offset as the distance from the mouse to the point of intersetion of a ray normal to the 
    # line containing the mouse vector.
    $vOffset = $vMouse.to3D().subtract( @_$l.intersectionWith( $L($vMouse, @_$vNormal) ) )
    # offset distance
    @options.offset = $vOffset.distanceFrom(Vector.Zero(3))
    # offset direction
    @options.offset *= -1 if $vOffset.dot(@_$vNormal.to3D()) < 0
    #@options.offset -= @offsetShift
    # updating the gui
    @element.attr @_attrs()


  _editTextStart: (e, field) ->
    $(field).requiredfield
      dataType: "distance"
      liveCheck: true
      functionValidate: (val) -> val != 0

    $(field).bind "validation", (e, valid) => ( @_textChange($(e.target)) if valid == true )


  _textChange: ($field) ->
    @_updateVariables()
    dimLength = $u($field.val())
    length = dimLength.as("mm").val()
    @unit = dimLength.currentUnit
    console.log $u($field.val())
    @points[1].move( @_$vUnitTangent.x(length).add(@points[0].$v), true, false )
    @render()


  _updateSelection: ->
    @sketch._selected.push(@_text) if @_text? and _.include(@sketch._selected, @_text) == false


  _afterDelete: () ->
    @_text.delete() if @_text?

