$ -> $.shape "circle",
  numberOfPoints: 1
  options:
    radius: 0

  _create: (ui) ->
    # ui: the circle is dragged with the mouse after the center point is created
    # any other time: the circle can be clicked to drag
    @dragging = ui

    # prefefined circle: set up the circle svg element and return
    return this._initCircle() unless ui == true

    # undefined circle: create the center point, then adjust the circle radius
    # 1) drag the point
    @_addPoint( type: "implicit" )
    # 2) place the point on click
    $(@points[0].node).one "aftercreate", (event, point) =>
      # 3) drag the circle
      @_initCircle()
      # 4) place the circle on click
      @sketch.$svg.one "click", (e) =>
        this.dragging = false
        this.$node.trigger("aftercreate")


  # initializes the circle svg element and it's events
  _initCircle: ->
    attrs = _.values(@_newElementAttr())
    @element = @sketch.paper.ellipse.apply( @sketch.paper, attrs )
    @_initElement()


  # moves the circle element based on mouse drag and drop actions
  _dragElement: (e, mouseVector) ->
    console.log("drag")
    @options.radius = mouseVector.distanceFrom( @sketch._pointToVector(this.points[0]) )
    @_afterPointMove()
    return true


  # update the circle's position when it's point moves
  _afterPointMove: ->
    this.element.attr( @_newElementAttr() ) if this.element?


  # creates the element attributes
  _newElementAttr: ->
    cx: @points[0].attr('x')
    cy: @points[0].attr('y')
    rx: @options.radius
    ry: @options.radius

