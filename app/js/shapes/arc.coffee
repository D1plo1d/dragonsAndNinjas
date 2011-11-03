
$ -> $.shape "arc",
  element: null
  numberOfPoints: 3
  options:
    type: "centerPoint"
    direction: 1


  _create: (ui) ->
    return unless ui == true

    # undefined arc: dependend on arc type
    capitalizedType = @options.type.charAt(0).toUpperCase() + @options.type.slice(1)
    this["_init#{capitalizedType}Arc"]()


  _initCenterPointArc: ->
    # TODO: (work in progress), probably should be moved to shape.. with on interactive create events feeding back
    console.log "making a fucking arc"
    # circle for construction purposes, used to show the user a circle of the radius of the curve
    @circleGuide = @_addGuide @sketch.paper.circle(10,20,30)
    @radiusGuide = @_addGuide @sketch.paper.path("M0,0L10,10")

    nextPoint = null
    console.log "f"
    f = () =>
      # unbind the previous point's create event
      console.log "next point!"

      # more points to create! keep going!
      if @points.length < @numberOfPoints
        console.log "next point! loading in!"
        nextPoint = @_addPoint()
        console.log nextPoint
        console.log $(nextPoint.node)
        $(nextPoint.node).one("aftercreate", f)

        if @points.length == 2
          @guides.show()
        if @points.length == 3
          console.log "mooo"
          @_initArc()
          @sketch.coradial(center: @points[0], points: @points[1..2])

        @_afterPointMove(@points[0])

      # final point created, finish the setup
      else
        @guides.remove()
        @$node.trigger("aftercreate", @element)

      return true
    console.log "setting up first point"
    f()
    console.log "set up"


  _initArc: ->
    console.log "setup the arc!"
    @_initElement @sketch.paper.path( "M0,0L0,0" )
    @_afterPointMove(@points[0])


  attrs: {}
  _attrs: -> @attrs

  _afterPointMove: (point) -> # called after _create whenever a point in options['points'] is moved
    # center point arc

    return if @points.length < 2

    # caching the points
    p = []
    for i in [0..@points.length-1]
      p[i] = @sketch._pointToVector(@points[i])


    # updating the on-screen arc segment
    if @options.type == "centerPoint"
      #TODO: placeholder for a proper direction property
      direction = @options.direction
      radius = p[0].distanceFrom(p[1])

      if p.length > 2 and @element?
        # calculating the central arc angle
        angle = []
        for i in [1..2]
          p_relative = p[i].subtract(p[0])
          angle[i] = Math.atan2(p_relative.elements[1], p_relative.elements[0])
        # the minor angle is the smaller of the two possible arc lengths from p[1] to p[2]
        minorAngle = angle[2] - angle[1]
        minorAngle -= Math.PI*2 if minorAngle > Math.PI
        minorAngle += Math.PI*2 if minorAngle < -Math.PI
        console.log minorAngle * 180 / Math.PI

        # caculating the svg A path's flags
        sweepFlag = if direction == 1 then 1 else 0
        largeArcFlag = if minorAngle * direction > 0 then 0 else 1

        # Creating the path string
        path = "M#{p[1].elements[0]}, #{p[1].elements[1]} "
        path +="A#{radius},#{radius}, 0, #{largeArcFlag}, #{sweepFlag}, #{p[2].elements[0]}, #{p[2].elements[1]}"

        this.attrs = path: path

      # updating the guides for interactive element creation
      if @circleGuide != null and @radiusGuide != null
        @circleGuide.attr(cx: @points[0].attr('x'), cy: @points[0].attr('y'), r: radius)
        @radiusGuide.attr "path",
          "M#{@points[0].attr('x')},#{@points[0].attr('y')}L#{@points[1].attr('x')},#{@points[1].attr('y')}"

