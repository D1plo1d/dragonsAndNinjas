$ -> $.shape "dimension",
  numberOfPoints: 2
  raphaelType: "path"
  textPadding:
    x: 10
    y: 5
  options:
    offset: 30


  _create: (ui) ->
    @_addNthPoint(@points.length, ui)


  # create the first point and then display the line while positioning the second
  _addNthPoint: (n, ui = true) ->
    if n < 2 then @_addPoint().$node.one "aftercreate", => @_addNthPoint(@points.length)

    if n >= 1 and @_text? == false then @_initText()

    # there is no point with index 2, finish the line creation
    @_afterCreate() if ui == true and n == 2


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
    tangent = @points[1].$v.subtract(@points[0].$v)
    normal = tangent.toUnitVector()
    normal.elements = [ -normal.elements[1], normal.elements[0] ]
    @_$vUnitTangent = tangent.toUnitVector()

    # calculate the endcap path strings
    direction = if @options.offset > 0 then 1 else -1
    endcapLength = 10 * @sketch._zoom.positionMultiplier

    endcapDistances = []
    endcapDistances[0] = @options.offset + endcapLength*direction
    endcapDistances[1] = -endcapLength*direction

    endcapPoints = ( normal.x(distance) for distance in endcapDistances )

    endcap = (dir) =>
      coord = (index, d = dir) => "#{endcapPoints[index].x(d).toPath()}"
      return "m#{coord(1)} l#{coord(0)}" if dir == -1
      return "l#{coord(0)} m#{coord(1)}" if dir == 1

    # position the dimension's text at the line's midpoint
    @_text_position = @points[0].$v.add( tangent.x(0.5) ).add( endcapPoints[0] ).add(endcapPoints[1] )
    length = tangent.distanceFrom(Vector.Zero(2))
    # TODO: proper precision
    length = Math.round(length*100)/100
    # TODO: proper units
    @_text.options.text = "#{length}mm"
    @_text.updateText()
    @_text.element.attr "font-size", 18 * @sketch._zoom.positionMultiplier


    # get the width of the text along the dimension's line (so we can allocate it some whitespace accordingly)
    textWidth = 0
    textWidth += Math.abs((@_text.$node.width()+@textPadding["x"]*@sketch._zoom.positionMultiplier)*@_$vUnitTangent.elements[0])
    textWidth += Math.abs((@_text.$node.height()+@textPadding["y"]*@sketch._zoom.positionMultiplier)*@_$vUnitTangent.elements[1])
    $vTextWidth = @_$vUnitTangent.x(textWidth) # TODO: some legit text width calculation

    # return the line, text and endcap path string
    $vHalfLine = tangent.subtract($vTextWidth).x(0.5)
    halfLine = $vHalfLine.toPath()

    # if the dimension is to small to fit a line and the text hide 
    # the line and show the text offset from the line instead.
    if $vHalfLine.isAntiparallelTo(tangent)
      # offsetting the text
      textOffset = endcapLength + @_text.$node.height()/2 + @textPadding["y"]
      @_text_position = @_text_position.add( normal.x(textOffset) )

      path = "M#{@points[0].$v.toPath()} #{endcap(1)} m#{tangent.toPath()} #{endcap(-1)}"

    # if the dimension is big enough show the text inline with the line.
    else
      path = "M#{@points[0].$v.toPath()} #{endcap(1)} l#{halfLine} m#{$vTextWidth.toPath()} l#{halfLine} #{endcap(-1)}"
    @_text.move(@_text_position)
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
    length = $u($field.val()).as("mm").val()
    @points[1].move( @_$vUnitTangent.x(length).add(@points[0].$v), true, false )
    @render()


  _updateSelection: ->
    @sketch._selected.push(@_text) if @_text? and _.include(@sketch._selected, @_text) == false


  _afterDelete: () ->
    @_text.delete() if @_text?

