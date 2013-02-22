
$ -> $.shape "arc",
  raphaelType: "path"
  numberOfPoints: 3
  options:
    type: "centerPoint"
    direction: 1


  _create: (ui) ->
    @presentAngle = 0
    if ui == false
      @_afterPointAdded()
      @_afterPointMove()
      @render()
    else
      # undefined arc: dependend on arc type
      capitalizedType = @options.type.charAt(0).toUpperCase() + @options.type.slice(1)
      this["_init#{capitalizedType}Arc"]()


  _initCenterPointArc: ->
    console.log "making a fucking arc"
    @_populatePoints()


  _populatePoints: ->
    if @points.length < @numberOfPoints
      @_addPoint().$node.one("aftercreate", @_populatePoints)
      @_afterPointAdded()
    else
      # final point created, finish the setup
      @guides.remove()
      @_afterCreate()


  _afterPointAdded: (point) ->
    console.log @points.length
    if @points.length == 2
      # circle for construction purposes, used to show the user a circle of the radius of the curve
      @circleGuide = @_addGuide @sketch.paper.circle(10,20,30)
      @radiusGuide = @_addGuide @sketch.paper.path("M0,0L10,10")

    if @points.length == 3
      @_initElement()
      @constraint = @sketch.coradial(center: @points[0], points: @points[1..2])


  direction: (direction) ->
    return @options.direction unless direction?
    @options.direction = direction
    @_afterPointMove(@points[0])
    console.log direction

  attrs: { path: "M0,0L0,0" }
  _attrs: -> @attrs

  _afterDelete: -> 
    @guides.remove() if @guides?
    console.log @constraint
    @constraint.delete() if @constraint?

  _afterPointMove: (point) -> # called after _create whenever a point in options['points'] is moved
    # center point arc
    T = 2*Math.PI # Tau = 2*pi

    return if @points.length < 2

    # caching the points
    p = []
    for i in [0..@points.length-1]
      p[i] = @points[i].$v

    # updating the on-screen arc segment
    if @options.type == "centerPoint"
      radius = p[0].distanceFrom(p[1])

      if @points.length > 2
        # calculating the central arc angle
        angle = []
        for i in [1..2]
          p_relative = p[i].subtract(p[0])
          angle[i] = Math.atan2(p_relative.elements[1], p_relative.elements[0])
        # the minor angle is the smaller of the two possible arc lengths from p[1] to p[2]
        minorAngle = angle[2] - angle[1]
        minorAngle -= T if minorAngle > Math.PI
        minorAngle += T if minorAngle < -Math.PI

        if minorAngle > 0
          angleA = minorAngle
          angleB = minorAngle - T
        else
          angleA = T + minorAngle
          angleB = minorAngle

        clockwise = Math.abs (angleA - @presentAngle) < Math.abs (angleB - @presentAngle)
        if clockwise
          direction = 1
          @presentAngle = angleA
        else
          direction = -1
          @presentAngle = angleB
        # caculating the svg A path's flags
        sweepFlag = if direction == 1 then 1 else 0
        largeArcFlag = if minorAngle * direction > 0 then 0 else 1
        # Creating the path string
        path = "M#{@points[1].x()}, #{@points[1].y()} "
        path +="A#{radius},#{radius}, 0, #{largeArcFlag}, #{sweepFlag}, #{@points[2].x()}, #{@points[2].y()}"

        this.attrs = path: path

      # updating the guides for interactive element creation
      if @circleGuide? and @radiusGuide? and @points.length >= 2
        @circleGuide.attr(cx: @points[0].x(), cy: @points[0].y(), r: radius)
        @radiusGuide.attr "path",
          "M#{@points[0].x()},#{@points[0].y()}L#{@points[1].x()},#{@points[1].y()}"

