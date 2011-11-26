$ -> $.shape "point",
  snappingDistance: 10
  radius: 5
  numberOfPoints: 0
  raphaelType: "text"
  xyPrefix: ""

  options: { type: "explicit", $v: null, x: null, y: null }


  _ui: (options) -> !( typeof(@options.x) == "number" and typeof(@options.y) == "number" or @options.$v? )


  _create: (ui) ->
    @_initVector(ui) # back end setup
    @_initSVG(ui) # front end setup

    @sketch._points.push this

    if ui == true then @sketch.$svg.one "click", =>
      @_afterCreate()
      return false


  _initVector: (ui) ->
    if ui == true
      @$v = $V([window.x, window.y])
    else
      @$v = if ( v = @options.$v )? then v else $V([@options.x, @options.y])


  _initSVG: (ui) ->
    @dragging = ui

    # variables required by the @_attrs() function
    if @options.type == "implicit"
      @raphaelType = "circle"
      @xyPrefix = "c"

    attrs = @_attrs()

    # appending the initialization constraints that aren't
    # normally included in attrs after initializing the element.
    if @options.type == "explicit"
      attrs["text"] = "*"
    else
      attrs["radius"] = @radius

    # initializing the svg element
    @_initElement(attrs)
    @element.toFront()
    @$node.addClass("#{@options.type}-point")


  _attrs: ->
    attrs = {}
    attrs["#{@xyPrefix}x"] = @$v.elements[0]
    attrs["#{@xyPrefix}y"] = @$v.elements[1]
    return attrs


  x: -> @$v.elements[0] #gets x


  y: -> @$v.elements[1] #gets y


  merge: (point) ->
    return if point.isDeleted() or this.isDeleted()
    console.log "merge #{point}"
    $nodes = $().add(point.$node).add(@$node)
    $nodes.trigger(type: "merge", deadPoint: point, mergedPoint: this)
    #TODO: proper merging of all objects that reference that point
    point.$node.unbind()
    point.delete()


  _afterDelete: ->
    @sketch._points = _.without(@sketch._points, this)


  _dragElement: (e, mouseVector) -> @move(mouseVector)


  _dropElement: ->
    @merge(@coincidentPoint) if @coincidentPoint?
    @coincidentPoint = null


  # move a point to a new absolute x/y position if it is not blocked by any constraints
  move: ($v, triggerConstraints = true) ->
    # alter the position to snap to nearby points if any exist
    nearestDistance = Number.MAX_VALUE
    nearestPoint = null

    for point in @sketch._points
      # check that the other point is not this point
      continue if this == point

      # check if the other point is within snapping distance of this point and it is the nearest point
      distance = $v.distanceFrom(point.$v)
      continue unless distance < @snappingDistance and distance < nearestDistance

      nearestDistance = distance
      nearestPoint = point

    # if a nearby snappable point was discovered, snap to it and record the 
    $v = nearestPoint.$v if nearestPoint?

    # Trigger a before move event and return if preventDefault is called by any handlers
    # This can be used by things like constraints to effect the positioning of points
    beforeMoveEvent = jQuery.Event "beforemove", 
      point: this
      triggerConstraints: triggerConstraints
      position: $v
    @$node.trigger(beforeMoveEvent)
    return if beforeMoveEvent.isDefaultPrevented()

    # move the element and trigger a move event
    @$v = $v
    @coincidentPoint = nearestPoint
    @element.attr @_attrs()
    @$node.trigger(jQuery.Event("move", point: this))




$ -> $.extend $.ui.sketch.prototype,
    # An array of all the points in the sketch
    _points: []
    # An array of all the shapes in the sketch
    _shapes: []


