$ -> $.shape "circle",
  options:
    x: 0, y: 0
    radius: 0

  _create: (ui) ->

    # initializes the circle svg element (later..)
    _createElement = =>
      this._initElement this.sketch.paper.ellipse.apply(this.sketch.paper, _.values this._newElementAttr())


    # create the center point, then adjust the circle radius
    if ui == true
      this.points[0] = this.sketch.point(type: "implicit")
      $(this.options.points[0].node).one "aftercreate", (event, point) =>
        _createElement()

        # dragging the circle with the mouse after the center point has been defined
        this.dragging = true
        dragCircle = (e) =>
          return true unless this.dragging == true

          mouseV = $V([e.pageX - this.sketch._position[0], e.pageY - this.sketch._position[1] - this.sketch.element.position().top])

          this.options.radius = mouseV.distanceFrom( this.sketch._pointToVector(this.points[0]) )
          this._afterPointMove()

          return true

        $svg = this.sketch.$svg
        $svg.bind "mousemove", dragCircle
        $svg.one "click", (e) =>
          this.dragging = false
          this.$node.bind "mousedown", =>
            console.log "down"
            this.dragging = true
            return true
          $("body").bind "mouseup", =>
            this.dragging = false
            return true

    else
      _createElement()


  _afterPointMove: ->
    this.element.attr( this._newElementAttr() ) if this.element?


  # creates the element attributes
  _newElementAttr: ->
    cx: this.points[0].attr('x')
    cy: this.points[0].attr('y')
    rx: this.options.radius
    ry: this.options.radius

