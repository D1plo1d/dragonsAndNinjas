$ -> $.shape "circle",
  numberOfPoints: 1
  raphaelType: "ellipse"
  options:
    radius: 0


  _create: (ui) ->
    return unless ui == true

    # undefined circle: create the center point, then adjust the circle radius
    # 1) drag the point and place the point on click
    @_addPoint().$node.one "aftercreate", =>
      # 2) drag the circle
      @dragging = true
      @_initElement()
      # 3) place the circle on click
      @sketch.$svg.one "click", (e) =>
        @_afterCreate()
        return false


  # moves the circle element based on mouse drag and drop actions
  _dragElement: (e, mouseVector) ->
    console.log("drag")
    @options.radius = mouseVector.distanceFrom( @points[0].$v )
    @element.attr @_attrs()


  # creates the element attributes
  _attrs: ->
    cx: @points[0].x()
    cy: @points[0].y()
    rx: @options.radius
    ry: @options.radius

