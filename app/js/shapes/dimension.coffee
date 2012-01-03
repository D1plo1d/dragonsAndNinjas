$ -> $.shape "dimension",
  numberOfPoints: 2
  raphaelType: "path"
  options:
    offset: 30


  _create: (ui) ->
    @_addNthPoint(@points.length, ui)


  # create the first point and then display the line while positioning the second
  _addNthPoint: (n, ui = true) -> switch n
    when 0, 1
      @_addPoint().$node.one "aftercreate", => @_addNthPoint(@points.length)
      if n == 1
        @_text = @sketch.paper.text(10,10, "0").hide()
        $(@_text.node).addClass("dimension-text")
        @_initElement()
        @_text.show()
    when 2 # there is no point with index 2, finish the line creation
      @_afterCreate() if ui == true


  _attrs: ->
    tangent = @points[1].$v.subtract(@points[0].$v)
    normal = tangent.toUnitVector()
    normal.elements = [ -normal.elements[1], normal.elements[0] ]

    # calculate the endcap path strings
    direction = if @options.offset > 0 then 1 else -1
    endcapPoints = ( normal.x(distance) for distance in [ @options.offset + 10*direction, -10*direction ] )
    endcap = (dir) =>
      coord = (index, d = dir) => "#{endcapPoints[index].x(d).toPath()}"
      return "m#{coord(1)} l#{coord(0)}" if dir == -1
      return "l#{coord(0)} m#{coord(1)}" if dir == 1

    # position the dimension's text at the line's midpoint
    text_position = @points[0].$v.add( tangent.x(0.5) ).add( endcapPoints[0] ).add(endcapPoints[1] )
    length = tangent.distanceFrom(Vector.Zero(2))
    # TODO: proper persision
    length = Math.round(length*100)/100
    # TODO: proper units
    @_text.attr( x: text_position.elements[0], y: text_position.elements[1], text: "#{length}mm" )

    # return the line, text and endcap path string
    textWidth = tangent.toUnitVector().x(100) # TODO: some legit text width calculation
    halfLine = tangent.subtract(textWidth).x(0.5).toPath()
    path: "M#{@points[0].$v.toPath()} #{endcap(1)} l#{halfLine} m#{textWidth.toPath()} l#{halfLine} #{endcap(-1)}"


  # Update the dimension's measurement graphic offset to the distance from the line
  # between the two points to the mouse vector.
  _dragElement: (e, mouseVector) ->
    # TODO: share this code with the attrs method better
    @_$vTangent = @points[1].$v.subtract(@points[0].$v)
    @_$vNormal = @_$vTangent.toUnitVector()
    @_$vNormal.elements = [ -@_$vNormal.elements[1], @_$vNormal.elements[0] ]

    @_$l = $L(@points[0].$v, @points[1].$v.subtract(@points[0].$v))

    # calculating the offset as the distance from the mouse to the point of intersetion of a ray normal to the 
    # line containing the mouse vector.
    $vOffset = mouseVector.to3D().subtract( @_$l.intersectionWith( $L(mouseVector, @_$vNormal) ) )
    # offset distance
    @options.offset = $vOffset.distanceFrom(Vector.Zero(3))
    # offset direction
    @options.offset *= -1 if $vOffset.dot(@_$vNormal.to3D()) < 0

    # updating the gui
    @element.attr @_attrs()


  _afterDelete: () ->
    $(@_text.node).unbind() if @_text?
    @_text.remove()
