$ -> $.shape "angle",
  numberOfPoints: 3
  raphaelType: "path"
  textPadding:
    x: 10
    y: 5
  options:
    presentAngle: 0


  _create: (ui) ->
    @unit="°"
    @_addNthPoint(@points.length, ui)
    @options.presentAngle = 0


  # create the first point and then display the line while positioning the second
  _addNthPoint: (n, ui = true) ->
    if n < 3 then @_addPoint().$node.one "aftercreate", => @_addNthPoint(@points.length)

    if n >= 2 and @_text? == false then @_initText()

    # there is no point with index 2, finish the line creation
    if ui == true and n == 3
      @constraint = @sketch.angleC(center: @points[0], points: @points[1..2], angle: @presentAngle)
      @_afterCreate()


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
    @presentAngle = @options.presentAngle
    T = 2*Math.PI # Tau = 2*pi

    if @points.length > 2
      @base = @points[0].$v
      @tangents = [@points[1].$v.subtract(@base), @points[2].$v.subtract(@base)]
      

      r = Math.min @tangents[0].modulus(), @tangents[1].modulus()
      r /= 2.3
      r = Math.min r, 30*@sketch._zoom.positionMultiplier

      @angles = (Math.atan2 p.elements[1], p.elements[0] for p in @tangents) 
      a = @angles[1] - @angles[0]
      a -= T if a > Math.PI
      a += T if a < -Math.PI
      if a > 0
          angleA = a
          angleB = a - T
        else
          angleA = T + a
          angleB = a

      clockwise = Math.abs (angleA - @presentAngle) < Math.abs (angleB - @presentAngle)
      if clockwise
        direction = 1
        @presentAngle = angleA
      else
        direction = -1
        @presentAngle = angleB
      @options.presentAngle = @presentAngle

      # Path calculations.
      sweepFlag = if direction == 1 then 1 else 0
      largeArcFlag = if a * direction > 0 then 0 else 1

      arcPoints = (@base.add(tg.toUnitVector().x(r)) for tg in @tangents)

      path = "M#{arcPoints[0].toPath()} "
      path +="A#{r},#{r}, 0, #{largeArcFlag}, #{sweepFlag}, #{arcPoints[1].toPath()}"

      # Text position calculuations
      midAngle = @angles[0] + @presentAngle/2 
      @midAngleV = $V([Math.cos(midAngle), Math.sin(midAngle) ])

      #textBox = $V([@_text.$node.width(), @_text.$node.height()])
      #textPadding = $V([@textPadding["x"], @textPadding["y"]])
      zoom = @sketch._zoom.positionMultiplier
      #textBox = textBox.add(textPadding.x(zoom))
      #textThickness = Math.abs textBox.dot(midAngleV)

      @_text_position = @base.add(@midAngleV.x(r + 19*zoom))

      @_text.move(@_text_position)
      @_text.options.text = "#{Math.abs(Math.round(@presentAngle*360/2/Math.PI))}°"
      @_text.updateText()
      @_text.element.attr "font-size", 18 * @sketch._zoom.positionMultiplier

      return path: path

    


  # dragging the dimension's text has the same effect as dragging the dimension's lines
  _dragText: (e, $vMouse) -> @_dragElement(e, $vMouse)


  _updateVariables: ->
    return


  # Update the dimension's measurement graphic offset to the distance from the line
  # between the two points to the mouse vector.
  _dragElement: (e, $vMouse) ->
    @_updateVariables()

    # calculating the offset as the distance from the mouse to the point of intersetion of a ray normal to the 
    # line containing the mouse vector.
    if $vMouse.subtract(@base).dot(@midAngleV) < 0
      @presentAngle = 2*Math.PI - @presentAngle
    # updating the gui
    @element.attr @_attrs()


  _editTextStart: (e, field) ->
    $(field).requiredfield
      dataType: "angle"
      liveCheck: true
      functionValidate: (val) -> val != 0

    $(field).bind "validation", (e, valid) => ( _.debounce(@_textChange, 300)($(e.target)) if valid == true )


  _textChange: ($field) ->
    #@_updateVariables()
    dimLength = $u($field.val())
    angle = dimLength.as("rad").val()
    @unit = dimLength.currentUnit
    @constraint.angle = angle
    @points[0].move(@points[0].$v) # trigger constraint solver
    #r = @tangents[1].modulus()
    #direction = if @presentAngle > 0 then 1 else -1
    #a = @angles[0] + direction*angle
    #@points[2].move(@base.add($V([Math.cos(a), Math.sin(a)]).x(r)))
    #@points[1].move( @_$vUnitTangent.x(length).add(@points[0].$v), true, false )
    @render()


  _updateSelection: ->
    @sketch._selected.push(@_text) if @_text? and _.include(@sketch._selected, @_text) == false


  _afterDelete: () ->
    @_text.delete() if @_text?
    @constraint.delete() if @constraint?

