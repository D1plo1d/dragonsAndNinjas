# TODO: rename equadistant/coradial
# TODO: constrains 2 sets of 2 points such that the 2 sets have equal radius or length
$ -> $.sketchExtension "distance",
  options:
    dist: 0
    points: []

  _create: ->
    # fail fast
    unless @options.points.length == 2
      throw "distance constraint requires two points to act on"

    @points = @options.points
    @_initPointEvents(point) for point in @points
    @sketch.constraints.push @


  _initPointEvents: (point) ->
    console.log @points.indexOf point
    point.$node.bind "beforemove", @_beforePointMove
    point.$node.bind "merge", @_mergePoint

  _unbindPointEvents: (point) ->
    point.$node.unbind "beforemove", @_beforePointMove
    point.$node.unbind "merge", @_mergePoint

  # todo: constraint merging and tracking
  merge: (constraint) ->
    return false

  delete: -> for point in @points
    @_unbindPointEvents point
    n = @sketch.constraints.indexOf(@)
    @sketch.constraints.splice(n,n)

  _mergePoint: (e) ->
    @_unbindPointEvents e.mergedPoint
    @_initPointEvents( e.mergedPoint )

    return true



  _beforePointMove: (e) ->
    console.log "distance called"
    return true if @alreadyApplied
    @alreadyApplied = true

    point = e.point
    other = if point == @points[0] then @points[1] else @points[0]

    return false if !other.freedom
    console.log "distance", @options.dist
    console.log "distance points", @points, @points[0] == e.point, @points[1] == e.point
    all_moves_succeed = true
    # repositioning each point in the constraint to maintain the constraint's assertions
    unit = other.$v.subtract(point.$v).toUnitVector()
    newOtherPosition = point.$v.add(unit.x(@options.dist))

    return other.move(newOtherPosition, true)

