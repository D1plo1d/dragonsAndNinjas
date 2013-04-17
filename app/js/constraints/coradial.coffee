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
    @sketch._constraints.push this 

  poly: () ->
    [a,b] = @points
    [an1, an2] = [a.n1, a.n2]
    [bn1, bn2] = [b.n1, b.n2]
    [cn1, cn2] = [@center.n1, @center.n2]
    return (vals) ->
      c1 = vals[cn1]
      c2 = vals[cn2]
      da = Math.sqrt(Math.pow(vals[an1]-c1,2) + Math.pow(vals[an2]-c2,2))
      db = Math.sqrt(Math.pow(vals[bn1]-c1,2) + Math.pow(vals[bn2]-c2,2))
      return 150*Math.abs(da-db)/(da+db)



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
    else if e.deadPoint == @center
      @center = e.mergedPoint
    else
      return true
    @_initPointEvents( e.mergedPoint )
    return true



  _beforePointMove: (e) ->
    return true 

