# TODO: rename equadistant/coradial
# TODO: constrains 2 sets of 2 points such that the 2 sets have equal radius or length
$ ->
  _create = $.ui.sketch.prototype._create

  $.extend $.ui.sketch.prototype,
    _create: ->
      _create.call(this)

      # after a point is dragged add a coincident constraint to any snapped points
      # or update their coincident constraint to include this point
      this.$svg.delegate ".arc", "aftercreate", (event) =>
        console.log "moooo"

      this.$svg.delegate ".point", "beforemove", (event) =>
        return true unless event.triggerConstraints == true && $(event.target).data("coradial")?
        # setup
        constraint = $(event.target).data("coradial")
        center_vector = this._pointToVector(constraint.center)


        # moving the center point
        if event.point == constraint.center
          radius = this._pointToVector(constraint.points[0]).distanceFrom(center_vector)
        # moving a coradial point
        else
          radius = this._pointToVector(event.point).distanceFrom(center_vector)


        for point in constraint.points
          continue if point == event.point
          point_vector = this._pointToVector(point)
          # console.log point_vector.inspect()
          unit_vector = point_vector.subtract(center_vector).toUnitVector()

          # calculate a new point at the same angle but with the updated radius of the dragged point
          point_vector = unit_vector.multiply(radius).add(center_vector)

          # update the point's position
          this.movePoint(point, point_vector.elements[0], point_vector.elements[1], false)


          # todo
          # coradial: (opts) -> this.colinear(opts)


          # todo
          # colinear: (opts) ->



    coradial: (opts) ->
      console.log "coincident created"
      defaults =
        points: []
        center: null
      opts = $.extend defaults, opts
      opts.type = "coradial"

      console.log "coradial1!!!!"
      # TODO: check for a previous coradial constraints on the center point and merge the new points into it if one exists
      ###
      for point in opts.points
        # check if the point has a pre-existing coincident constraint
        continue unless ( coincident = $(point.node).data "coincident" )?
        # if it does delete it and add it's points onto this coincident constraint
        for coincidentPoint in coincident.points
          opts.points.push coincidentPoint
          $node = $(coincidentPoint.node)
          $node.data "constraints", _.without( $node.data("constraints"), coincident )
      ###

      # the points list should contain no duplicates
      opts.points = _.unique opts.points

      # store the constraint in the point's jquery data
      for p_array in [opts.points, [opts.center]]
        for p in p_array
          $node = $(p.node)
          # each node has one or zero coincident constraints attached to it 
          # via it's coincident jquery data
          $node.data( "coradial", opts )
          # all constraints for each point are stored in the points constraints array
          constraints = [] unless ( constraints = $node.data("constraints") )?
          constraints.push opts
          $node.data( "constraints", constraints )

