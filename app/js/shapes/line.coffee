
$ ->
  $.extend $.ui.sketch.prototype,
    line: (opts = false) ->
      defaults =
        x0: 0, y0: 0
        x1: 0, y1: 0
        points: []
      undefinedOpts = opts == false
      opts = $.extend defaults, opts

      # Points can be defined by x/y coordinates as well for simplicity.
      # if they are definted that way, create new end points.
      if undefinedOpts == false
        points = opts.points
        for i in [points.length .. 1]
          points[i] = this.point(type: "implicit", x: opts["x#{i}"], y: opts["y#{i}"])
          points[i].hide() if undefinedOpts == true


      # initializing the line svg / dom element
      updatePath = =>
        path = "M#{points[0].attr('x')}, #{points[0].attr('y')}L#{points[1].attr('x')},#{points[1].attr('y')}"
        element.attr path: path

      element = this.paper.path( "M0,0L0,0" ).toBack()


      finishInit = =>
        $node = $(element.node).addClass("line")
        updatePath()
        this.root.push(element)

        # selection event listeners
        $node.click (e) => this.select(element)

        # point move event listeners
        for p in points
          $(p.node).bind "move", updatePath

        $node.trigger("aftercreate", element)


      # undefined line -> interactive (ui) creation
      # TODO: (work in progress), probably should be moved to point.. with on interactive create events feeding back
      if undefinedOpts == true
        points = [ this.point(type: "implicit") ]
        this.element.bind "aftercreate", f = (event, element) =>
          return true unless element == points[0]
          this.element.unbind("aftercreate", f)
          points[1] = this.point(type: "implicit")
          finishInit()

      else
        finishInit()

      return element
