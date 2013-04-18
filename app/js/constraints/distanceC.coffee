
$ -> $.sketchExtension "distanceC",
  options:
    points: []

  _create: ->
    # fail fast
    unless @options.points.length == 2 and @options.dist
      throw "distance requires 2 points and a distance"

    @points = @options.points
    @dist = @options.dist
    @_initPointEvents(point) for point in @points
    @sketch._constraints.push this 

  poly: () ->
    [a,b] = @points
    [an1, an2] = [a.n1, a.n2]
    [bn1, bn2] = [b.n1, b.n2]
    dist = @dist
    f= (vals) ->
      return Math.abs(Math.pow(vals[an1]-vals[bn1],2) + Math.pow(vals[an2]-vals[bn2],2) - dist*dist)/dist
    f.vars = [an1, an2, bn1, bn2]
    return f



  _initPointEvents: (point) ->
    point.$node.bind "beforemove", @_beforePointMove
    point.$node.bind "merge", @_mergePoint


  # todo: constraint merging and tracking
  merge: (constraint) ->
    return false

  delete: -> for point in @points
    point.$node.unbind "beforemove", @_beforePointMove
    point.$node.unbind "merge", @_mergePoint
    @sketch._constraints = _.without(@sketch._constraints, this)



  _mergePoint: (e) ->
    #console.log "merging?"
    index = _.indexOf(@points, e.deadPoint)
    if index != -1
      return false if e.deadPoint == @center
      @points[index] = e.mergedPoint
    else
      return true
    @_initPointEvents( e.mergedPoint )
    return true



  _beforePointMove: (e) ->
    return true 

