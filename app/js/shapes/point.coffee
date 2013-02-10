$ -> $.shape "point",
  snappingDistance: 10
  radius: 5
  numberOfPoints: 0
  raphaelType: "text"
  xyPrefix: ""

  options: { type: "explicit", $v: null, x: null, y: null }


  _ui: (options) -> !( typeof(@options.x) == "number" and typeof(@options.y) == "number" or @options.$v? )


  _create: (ui) ->
    @$v_consider = $V([0, 0])

    @_initVector(ui) # back end setup
    @_initSVG(ui) # front end setup

    @sketch._points.push this # todo: move this to after create for consitency with _shapes

    if ui == true then @sketch.$svg.one "click", =>
      @_afterCreate()
      return false


  _initVector: (ui) ->
    if ui == true
      @$v = @sketch._$vMouse( $V [window.x, window.y] )
    else
      @$v = if ( v = @options.$v )? then v else $V([@options.x, @options.y])


  _initSVG: (ui) ->
    @dragging = ui

    # variables required by the @_attrs() function
    if @options.type == "implicit"
      @raphaelType = "circle"
      @xyPrefix = "c"

    @sketch.$svg.bind "zoomchange", @_zoomChange
    attrs = @_attrs()

    # appending the initialization constraints that aren't
    # normally included in attrs after initializing the element.
    if @options.type == "explicit"
      attrs["text"] = "*"

    # initializing the svg element
    @_initElement(attrs)
    @element.toFront()
    @$node.addClass("#{@options.type}-point")

    # If there is a point already at the same [x,y] position in the sketch merge with it if ui != true
    unless ui == true
      @coincidentPoint = @_snapToNearestPoint(@$v, 0)
      @_mergeCoincidentPoint()
      @render()



  _attrs: ->
    attrs = {}
    attrs["#{@xyPrefix}x"] = @$v.elements[0]
    attrs["#{@xyPrefix}y"] = @$v.elements[1]
    attrs["r"] = (@radius * @sketch._zoom.positionMultiplier) if @options.type == "implicit"
    return attrs


  x: -> @$v.elements[0] #gets x


  y: -> @$v.elements[1] #gets y


  _zoomChange: () ->
    @render()
    return true


  merge: (point) ->
    return if point.isDeleted() or this.isDeleted()
    #console.log "merge #{point}"
    $nodes = $().add(point.$node).add(@$node)
    $nodes.trigger(type: "merge", deadPoint: point, mergedPoint: this)
    #TODO: proper merging of all objects that reference that point
    point.$node.unbind()
    point.delete()


  _afterDelete: ->
    @sketch._points = _.without(@sketch._points, this)


  _dragElement: (e, mouseVector) -> @move(mouseVector)


  _dropElement: -> @_mergeCoincidentPoint()


  _mergeCoincidentPoint: ->
    @merge(@coincidentPoint) if @coincidentPoint?
    @coincidentPoint = null


  # Sets the vectors elements to those of the nearest point within snapping distance or leaves them unchanged
  # if there is no point close enough to snap to.
  #
  # Returns the nearest snappable point or null if no point is close enough to snap to.
  _snapToNearestPoint: ($v, snappingDistance = @snappingDistance * @sketch._zoom.positionMultiplier) ->
    nearestPoint = null
    nearestDistance = Number.MAX_VALUE

    for point in @sketch._points
      # check that the other point is not this point
      continue if this == point

      # check if the other point is within snapping distance of this point and it is the nearest point
      distance = $v.distanceFrom(point.$v)
      continue unless distance <= snappingDistance and distance < nearestDistance

      nearestDistance = distance
      nearestPoint = point

      # if a nearby snappable point was discovered, snap to it and record the 
      $v.elements = nearestPoint.$v.elements if nearestPoint?
      return nearestPoint

  move_consider: ($v) ->
    @$v_consider.elements[i] = $v.elements[i] for i in [0,1]
    @freedom = false
    beforeMoveEvent = jQuery.Event "beforemove", 
      point: this
      causedByConstraint: true
      position: $v
    @$node.trigger(beforeMoveEvent)
    return !( beforeMoveEvent.isDefaultPrevented() )


  # move a point to a new absolute x/y position if it is not blocked by any constraints
  move: ($v, causedByConstraint = false, snapping = true) ->
    #console.log "moo: move!"
    # snap the point to the closest point within snapping distance if this snapping is enabled for this move.
    nearestPoint = if snapping == true then @_snapToNearestPoint($v) else null

    if !causedByConstraint
      for point in @sketch._points
        point.freedom = true
        point.$v_consider.elements[i] = point.$v.elements[i] for i in [0,1]
        point.consider_stack = []
      constraint.alreadyApplied = false for constraint in @sketch.constraints

    # Trigger a before move event and return if preventDefault is called by any handlers
    # This can be used by things like constraints to effect the positioning of points
    return false unless @move_consider($v) == true

    # move the element and trigger a move event
    @coincidentPoint = nearestPoint
    for p in @sketch._points
      p._move p.$v_consider

  _move: ($v) -> if $v.elements[0] != @$v.elements[0] and $v.elements[1] != @$v.elements[1]
    @$v.elements[i] = $v.elements[i] for i in [0,1]
    @element.attr @_attrs()
    @$node.trigger(jQuery.Event("move", point: @))


  _serialize: (obj_hash) ->
   {shapeType: @shapeType, type: @options.type, x: @$v.elements[0], y: @$v.elements[1] }


