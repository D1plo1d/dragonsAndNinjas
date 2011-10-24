
$ ->
  $.extend $.ui.sketch.prototype,
    arc: (opts = false) ->
      defaults =
        type: "centerPoint"
        x0: 0, y0: 0
        x1: 0, y1: 0
        x2: 0, y2: 0
        points: []
      undefinedOpts = opts == false
      opts = $.extend defaults, opts
      number_of_points = 2

      # Points can be defined by x/y coordinates as well for simplicity.
      # if they are definted that way, create new end points.
      if undefinedOpts == false
        points = opts.points
        for i in [points.length .. 1]
          points[i] = this.point(type: "implicit", x: opts["x#{i}"], y: opts["y#{i}"])
          points[i].hide() if undefinedOpts == true



      # initializing the line svg / dom element
      updatePath = =>
        # center point arc

        return true if points.length < 2

        # caching the points
        p = []
        for i in [0..points.length-1]
          p[i] = []
          for axis in ['x', 'y']
            p[i][axis] = points[i].attr(axis)

        # calculating the arc radius
        radius = 0
        if opts.type == "centerPoint"
          radius = Raphael.distance(p[0..1])

        # updating the guides for interactive element creation
        if undefinedOpts == true
          circleGuide.attr(cx: points[0].attr('x'), cy: points[0].attr('y'), r: radius)
          radiusGuide.attr "path",
            "M#{points[0].attr('x')},#{points[0].attr('y')}L#{points[1].attr('x')},#{points[1].attr('y')}"

        if p.length > 2
          # calculating the arc angle
          angle = ( (Math.atan2(p[2].y - p[1].y, p[2].x - p[1].x) + Math.PI) % Math.PI ) - Math.PI / 2
          #console.log angle
          # console.log angle

          # caculating the svg A path's flags
          sweepFlag = if angle < Math.PI / 2 then 1 else 0
          largeArcFlag = if Math.abs(angle) > Math.PI / 2 then 1 else 0

          # Creating the path string
          path = "M#{p[1].x}, #{p[1].y} "
          path +="A#{radius},#{radius}, 0, #{largeArcFlag}, #{sweepFlag}, #{p[2].x}, #{p[2].y}"
          # console.log path
          element.attr path: path
          #console.log path

        return true



      element = this.paper.path( "M0,0L0,0" ).toBack()
      this.root.push(element)
      $node = $(element.node).addClass("arc").hide()



      finishInit = =>
        # If the arc was defined by the gui note that it is now no longer undefined
        undefinedOpts = false

        # point move event listeners
        for p in points
          $(p.node).bind "move", updatePath

        updatePath()
        $node.show()

        # selection event listeners
        $node.click (e) => this.select(element)

        $node.trigger("aftercreate", element)


      # undefined line -> interactive (ui) creation
      # TODO: (work in progress), probably should be moved to point.. with on interactive create events feeding back
      if undefinedOpts == true
        console.log "making a fucking arc"
        # circle for construction purposes, used to show the user a circle of the radius of the curve
        circleGuide = this.paper.circle(10,20,30)
        radiusGuide = this.paper.path("M0,0L10,10")
        this.guides = this.paper.set()
        this.guides.push(radiusGuide)
        this.guides.push(circleGuide)
        this.guides.hide()

        $(radiusGuide.node).add($(circleGuide.node)).addClass("creation-guide")
        # setting up the first point
        points = [ this.point(type: "implicit") ]
        $(points[0].node).bind "move", updatePath

        this.element.bind "aftercreate", f = (event, element) =>
          return true unless element == points[points.length-1]

          if points.length - 1 < number_of_points
            # more points to create! keep going!
            points[points.length] = ( p = this.point(type: "implicit") )
            $(p.node).bind "move", updatePath
          else
            # final point created, finish the setup
            this.element.unbind("aftercreate", f)
            this.guides.remove()
            finishInit()

          if points.length == 2
            this.guides.show()
          if points.length == 3
            $node.show()
            this.coradial(center: points[0], points: points[1..2])

          updatePath()

      else
        finishInit()

      return element
