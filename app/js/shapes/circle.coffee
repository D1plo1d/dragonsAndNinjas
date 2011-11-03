$ -> $.shape "circle",
  numberOfPoints: 1
  raphaelType: "ellipse"
  options:
    radius: 0


  _create: (ui) ->
    return unless ui == true

    # undefined circle: create the center point, then adjust the circle radius
    # 1) drag the point
    @_addPoint()
    # 2) place the point on click
    $(@points[0].node).one "aftercreate", (event, point) =>
      # 3) drag the circle
      @dragging = true
      @_initElement()
      # 4) place the circle on click
      @sketch.$svg.one "click", (e) =>
        this.dragging = false
        this.$node.trigger("aftercreate")


  # moves the circle element based on mouse drag and drop actions
  _dragElement: (e, mouseVector) ->
    console.log("drag")
    @options.radius = mouseVector.distanceFrom( @sketch._pointToVector(this.points[0]) )
    @element.attr @_attrs()


  # creates the element attributes
  _attrs: ->
    cx: @points[0].attr('x')
    cy: @points[0].attr('y')
    rx: @options.radius
    ry: @options.radius

