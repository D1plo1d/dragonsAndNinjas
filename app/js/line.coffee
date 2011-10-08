
$ ->
  $.extend $.ui.sketch.prototype,
    line: (opts) ->
      defaults =
        x0: 0, y0: 0
        x1: 0, y1: 0
        points: []
      opts = $.extend defaults, opts
      # Points can be defined by x/y coordinates as well for simplicity.
      # if they are definted that way, create new end points.
      points = opts.points
      for i in [points.length - 1 .. 1]
        points[i] = this.point(type: "implicit", x: opts["x#{i}"], y: opts["y#{i}"])

      # initializing the line svg / dom element
      pathString = =>
        return "M#{points[0].attr('x')}, #{points[0].attr('y')}L#{points[1].attr('x')},#{points[1].attr('y')}"
      element = this.paper.path( pathString() ).toBack()

      $node = $(element.node).addClass("line")
      this.root.push(element)

      # selection event listeners
      $node.click (e) => this.select(element)

      # point move event listeners
      for p in points
        $(p.node).bind "move", =>
          element.attr path: pathString()
