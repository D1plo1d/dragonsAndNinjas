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
    @_initPoint(point) for point in @points


  _initPoint: (point) ->
    point.$node.bind "beforemove", @_beforePointMove


  # todo: constraint merging and tracking
  _merge: (constraint) -> return false


  _beforePointMove: (e) ->
    return true unless e.triggerConstraints == true

    # calculating the new radius for both scenarios:
    # either we are moving the center point or a point along the circle
    anotherPoint = if e.point == @center then @points[0] else @center
    radius = e.position.distanceFrom(anotherPoint.$v)

    # repositioning each point in the constraint to maintain the constraint's assertions
    for point in @points
      continue if point == e.point

      unit_vector = point.$v.subtract(@center.$v).toUnitVector()

      # calculate a new point at the same angle but with the updated radius of the dragged point
      point_vector = unit_vector.multiply(radius).add(@center.$v)

      # update the point's position
      point.move(point_vector, false)

    return true

