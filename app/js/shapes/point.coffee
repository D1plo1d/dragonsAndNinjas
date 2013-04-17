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
    @n = 0

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


  # move a point to a new absolute x/y position if it is not blocked by any constraints
  move: ($v, triggerConstraints = true, snapping = true) ->
    # snap the point to the closest point within snapping distance if this snapping is enabled for this move.
    nearestPoint = if snapping == true then @_snapToNearestPoint($v) else null

    n=0
    varmap = []
    for p in @sketch._points
      p.n1 = n++ 
      p.n2 = n++ 
      varmap.push p.$v.elements[i] for i in [0,1]
    
    polys = []
    polys.push(c.poly()) for c in @sketch._constraints
    #console.log "polys", polys
    varmap[@n1] = $v.elements[0]
    varmap[@n2] = $v.elements[1]
    #console.log "init", varmap
    initial = varmap.slice(0)
    k=0.01
    for _ in [0...200]
      varmapMod = varmap.slice(0)
      for v in [0.. n-1]
        continue if v == @n1 or v == @n2
        satisfied=true
        for f in polys
          val1 = f varmap
          if val1 < 0.005
            continue
          else
            satisfied = false
          varmap[v] -= 0.005
          val2 = f varmap
          varmap[v] += 0.005
          varmapMod[v] -= 0.08*val1*(val1-val2)/0.01
          #console.log val1, val2, 0.13*val1*(val1-val2)/0.1
        break if satisfied
        varmap[v] -= 0.002*(varmap[v]-initial[v])
      varmap=varmapMod
    #console.log "end", varmap

    @coincidentPoint = nearestPoint
    for p in @sketch._points
      p.$v.elements[0] = varmap[p.n1] 
      p.$v.elements[1] = varmap[p.n2]
      p.element.attr p._attrs()
      p.$node.trigger(jQuery.Event("move", point: p))


  _serialize: (obj_hash) ->
   {shapeType: @shapeType, type: @options.type, x: @$v.elements[0], y: @$v.elements[1] }


