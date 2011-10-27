
$ ->
  $.extend $.ui.sketch.prototype,
    circle: (opts = false) ->
      defaults =
        x: 0, y: 0
        radius: 0
        points: []
      undefinedOpts = opts == false
      opts = $.extend defaults, opts

      # Points can be defined by x/y coordinates as well for simplicity.
      # if they are definted that way, create new end points.
      if undefinedOpts == false
        points = opts.points
        for i in [points.length .. 1]
          points[i] = this.point(type: "implicit", x: opts["x"], y: opts["y"])
          points[i].hide() if undefinedOpts == true


      # initializing the line svg / dom element
      updatePath = =>
        element.attr x: points[0].attr('x'), y: points[0].attr('y'), rx: opts.radius, ry: opts.radius

      element = this.paper.ellipse(opts.x, opts.y, opts.radius, opts.radius).toBack()
      this.root.push(element)


      finishInit = =>
        $node = $(element.node).addClass("circle")
        updatePath()

        # selection event listeners
        $node.click (e) => this.select(element)

        # point move event listeners
        for p in points
          $(p.node).bind "move", updatePath

        $node.trigger("aftercreate", element)


      # undefined circle -> interactive (ui) creation
      # TODO: (work in progress), probably should be moved to point.. with on interactive create events feeding back
      if undefinedOpts == true
        points = [ this.point(type: "implicit") ]
        this.element.bind "aftercreate", f = (event, element) =>
          return true unless element == points[0]
          this.element.unbind("aftercreate", f)
          # TODO: circle dragging and dropping
          # finishInit()

      else
        finishInit()

      return element
