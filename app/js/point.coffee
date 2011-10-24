snappingDistance = 10

$ ->
  _init = $.ui.sketch.prototype._init

  $.extend $.ui.sketch.prototype,

    # A rapael set of all the points in the sketch
    _points: null


    _init: ->
      _init()
      this._points = this.paper.set()
      this.root.push this._points



    # accepts a point or jquery object [or dom object] of a point and returns it's position as a vector
    _pointToVector: (p) =>
      return Vector.Zero(2) unless p?

      if p.constructor.prototype == Raphael.el
        $node = $(p.node)
      else if p instanceof jQuery
        $node = p
        console.log $node
        console.log $node.attr("x")
      else # otherwise assume it is a dom object
        $node = $(p)

      values = []
      for axis in ["x","y"]
        v = $node.attr(axis)
        v = $node.attr("c#{axis}") if isNaN(v)
        values.push if isNaN(v) then 0 else v

      return Vector.create(values)


    # move a point to a new absolute x/y position if it is not blocked by any constraints
    movePoint: (element, x = 0, y = 0, triggerConstraints = true) ->
      $node = $(element.node)
      pos = x: x, y: y

      # alter the position to snap to nearby points if any exist
      nearestDistance = Number.MAX_VALUE
      nearestPoint = null
      for point in this._points
        # check that the other point is not this point or a coincidently constrained point
        continue if (element == point)
        # hmm.. any way not to tightly bind points to coincident?
        continue if (c = $node.data("coincident"))? and _.indexOf(c.points, point) != -1

        # check if the other point is within snapping distance of this point
        inRange = true
        d = []
        for ax in ["x", "y"]
          d[ax] = Math.abs(pos[ax] - point.attr(ax))
          inRange = inRange and d[ax] < snappingDistance

        # if it is within snapping distance check that it is the nearest point
        continue unless inRange == true
        distance = Math.sqrt( d["x"] ^ 2 + d["y"] ^2 )
        continue unless distance < nearestDistance

        nearestDistance = distance
        nearestPoint = point

      # if a nearby snappable point was discovered, snap to it and record the 
      if nearestPoint?
        pos[ax] = nearestPoint.attr(ax) for ax in ["x", "y"]

      $node.data("snappedPoint", nearestPoint)

      # if nearestPoint? then console.log $node.data("snappedPoint")

      # Trigger a before move event and return if preventDefault is called by any handlers
      # This can be used by things like constraints to effect the positioning of points
      beforeMoveEvent = jQuery.Event "beforemove", 
        point: element
        x: pos.x
        y: pos.y
        triggerConstraints: triggerConstraints
      $node.trigger(beforeMoveEvent)
      return if beforeMoveEvent.isDefaultPrevented()

      # include circle cx/cy positions in the elements attributes for implicit points
      pos["c#{axis}"] = pos[axis] for axis in ["x", "y"]

      # move the element and trigger a move event
      element.attr pos
      $node.trigger("move")



    # implicit:
    #   points added as a sub components of one or more parent elements (ex: the 2 end points of a line)
    # explicit:
    #   points created explicitly by the user or explicitly selected to persist even 
    #   if all it's related parent elements are destroyed
    point: (opts = false) ->
      defaults =
        type: "explicit"
        x: 0
        y: 0
      undefinedOpts = opts == false or (opts.x? and opts.y?) == false
      opts = $.extend defaults, opts

      throw "invalid pointer type: #{type}" unless opts.type == "implicit" or opts.type == "explicit"

      # initializing the svg / dom element
      switch opts.type
        when "implicit"
          element = this.paper.circle(opts.x,opts.y, 5).attr(x: opts.x, y: opts.y)
          $node = $(element.node)
        when "explicit"
          element = this.paper.text(opts.x, opts.y, "*")
          $node = $(element.node).find("tspan")

      $node.addClass("#{opts.type}-point").addClass("point")
      this._points.push(element)


      # initialize the point's ui events (after it has been created [through drag and drop or parameters]
      initEvents = =>
        $node.click (e) =>
          this.select(element)
          e.stopPropagation()
          return true

        # Updating the x/y attributes on scroll
        if opts.type == "implicit"
         this.element.bind "translate", => element.attr x: element.attr("cx"), y: element.attr("cy")


        # mouse interactions
        xy_attr = if opts.type == "implicit" then {x: "cx", y: "cy"} else {x:"x", y:"y"}
        drag_offset = []

        start = (x, y, event) =>
          drag_offset = [element.attr(xy_attr.x) - x, element.attr(xy_attr.y) - y]

        move = (dx, dy, x, y, event) =>
          this.movePoint element, x + drag_offset[0], y + drag_offset[1]

        end = (event) =>
          $node.trigger($.Event "afterpointdrag", point: element)

        element.drag move, start, end

        $node.trigger("aftercreate", element)


      # if this point has an undefined position default to interactive positioning (drag and drop point creation)
      if undefinedOpts == true
        this.$svg.bind "mousemove", f = (e) =>
          this.movePoint(element, e.pageX + this._position[0], e.pageY + this._position[1] - this.element.position().top)
        this.$svg.one "click", (e) =>
          f(e)
          this.$svg.unbind("mousemove", f)
          initEvents()
      else
        initEvents()

      return element

