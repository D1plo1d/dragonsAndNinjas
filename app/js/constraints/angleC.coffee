
$ -> $.sketchExtension "angleC",
  options:
    points: []

  _create: ->
    # fail fast
    unless @options.points.length == 2 and @options.center and @options.angle
      throw "distance requires 2 points, center, and a angle"

    @points = @options.points
    @center = @options.center
    @angle = @options.angle
    @_initPointEvents(point) for point in @points
    @_initPointEvents(@center)
    @sketch._constraints.push this 

  poly: () ->
    [a,b] = @points
    [an1, an2] = [a.n1, a.n2]
    [bn1, bn2] = [b.n1, b.n2]
    [cn1, cn2] = [@center.n1, @center.n2]
    [cos, sin] = [Math.cos(@angle), Math.sin(@angle)]
    return (vals) ->
      [a1,a2] = [vals[an1],vals[an2]]
      [b1,b2] = [vals[bn1],vals[bn2]]
      [c1,c2] = [vals[cn1],vals[cn2]]
      [p1,p2] = [a1 - c1, a2 - c2]
      [q1,q2] = [b1 - c1, b2 - c2]
      angleProd  = sin*p1*q1 + cos*p1*q2 - cos*p2*q1 + sin*p2*q2
      #angleProd2 = sin*p1*q1 - cos*p1*q2 + cos*p2*q1 + sin*p2*q2
      #angleProd = Math.min(angleProd1, angleProd2)
      return 180*Math.sqrt(angleProd*angleProd/ (q1*q1+q2*q2) / (p1*p1+p2*p2))



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

