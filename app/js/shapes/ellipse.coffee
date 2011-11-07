$ -> $.shape "ellipse",
  numberOfPoints: 1
  raphaelType: "ellipse"
  options:
    rx: 0
    ry: 0
    rotation: 0
  raphaelRotation: 0


  _create: (ui) ->
    return unless ui == true

    # undefined circle: create the center point, then adjust the circle radius
    # 1) drag the 1st point. place the point on click
    @_addPoint().$node.one "aftercreate", =>
      # 2) drag the ellipse
      @dragging = true
      @_initElement()
      console.log "after create"
      # 3) place the circle on click
      @sketch.$svg.one "click", (e) =>
        console.log 'done here'
        @_afterCreate()
        return false


  # moves the ellipse element based on mouse drag and drop actions
  _dragElement: (e, mouseVector) ->
    console.log("drag")
    distanceVector = mouseVector.subtract( @points[0].$v )
    @options.rx = Math.abs distanceVector.elements[0]
    @options.ry = Math.abs distanceVector.elements[1]
    @element.attr @_attrs()


  # creates the element attributes
  _attrs: ->
    attrs = 
      cx: @points[0].x()
      cy: @points[0].y()
      rx: @options.rx
      ry: @options.ry
    @element.rotate(@options.rotation - @raphaelRotation, attrs.cx, attrs.cy) if @element?
    @raphaelRotation = @options.rotation
    return attrs

