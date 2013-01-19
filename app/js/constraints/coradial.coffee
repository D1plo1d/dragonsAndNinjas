# TODO: rename equadistant/coradial
# TODO: constrains 2 sets of 2 points such that the 2 sets have equal radius or length
$ -> $.sketchExtension "coradial",
  options:
    points: []
    center: null

  _create: ->
    # fail fast
    unless @options.points.length >= 2 and @options.center?
      throw "coradial requires at least 2 points about a center point"

    @points = @options.points
    @center = @options.center
    @_initPointEvents(@center)
    @_initPointEvents(point) for point in @points
    @sketch.constraints.push @


  _initPointEvents: (point) ->
    point.$node.bind "beforemove", @_beforePointMove
    point.$node.bind "merge", @_mergePoint


  # todo: constraint merging and tracking
  merge: (constraint) ->
    return false

  delete: -> for point in @points
    point.$node.unbind "beforemove", @_beforePointMove
    point.$node.unbind "merge", @_mergePoint
    n = @sketch.constraints.indexOf(@)
    @sketch.constraints.splice(n,n)

  _mergePoint: (e) ->
    #console.log "merging?"
    index = _.indexOf(@points, e.deadPoint)
    if index != -1
      return false if e.deadPoint == @center
      @points[index] = e.mergedPoint
    else if e.deadPoint == @center
      @center = e.mergedPoint
    else
      return true
    @_initPointEvents( e.mergedPoint )
    return true



  _beforePointMove: (e) ->
    console.log "coradial called"
    return true if @alreadyApplied
    @alreadyApplied = true
    console.log "coradial not applied: proceeding"

    # calculating the new radius for both scenarios:
    # either we are moving the center point or a point along the circle
    anotherPoint = if e.point == @center then @points[0] else @center
    radius = e.position.distanceFrom(anotherPoint.$v)

    for point in @points isnt e.point
      insufficientlyFree = true if !point.freedom
    return false if insufficientlyFree?
    console.log "coradial points not bound: proceeding!"

    console.log "coradial points", @points, @points[0] == e.point, @points[1] == e.point
    all_moves_succeed = true
    # repositioning each point in the constraint to maintain the constraint's assertions
    for point in @points
      console.log "coradial point", point
      continue if point == e.point

      unit_vector = point.$v.subtract(@center.$v).toUnitVector()

      # calculate a new point at the same angle but with the updated radius of the dragged point
      point_vector = unit_vector.multiply(radius).add(@center.$v)

      # update the point's position
      move_success = point.move(point_vector, true)

      all_moves_succeed = all_moves_succeed and move_success

    return all_moves_succeed

