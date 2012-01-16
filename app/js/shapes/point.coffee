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
  move: ($v, triggerConstraints = true, snapping = true) ->
    nearestPoint = null

    if snapping == true
      snappingDistance = @snappingDistance * @sketch._zoom.positionMultiplier
      # alter the position to snap to nearby points if any exist
      nearestDistance = Number.MAX_VALUE

      for point in @sketch._points
        # check that the other point is not this point
        continue if this == point

        # check if the other point is within snapping distance of this point and it is the nearest point
        distance = $v.distanceFrom(point.$v)
        continue unless distance < snappingDistance and distance < nearestDistance

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
    @$v.elements[i] = $v.elements[i] for i in [0,1]
    @coincidentPoint = nearestPoint
    @element.attr @_attrs()
    @$node.trigger(jQuery.Event("move", point: this))


  _serialize: (obj_hash) ->
   {shapeType: @shapeType, type: @options.type, x: @$v.elements[0], y: @$v.elements[1] }


