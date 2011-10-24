# A cheap hack to demo how constraint functionality would be inserted into the logic
# prevent default could be used by the event to set a different position for the point.
$ ->
  _create = $.ui.sketch.prototype._create

  $.extend $.ui.sketch.prototype,
    _create: ->
      _create.call(this)

      # after a point is dragged add a coincident constraint to any snapped points
      # or update their coincident constraint to include this point
      this.$svg.delegate ".point", "afterpointdrag aftercreate", (event) =>
        console.log "moooo"
        $node = $(event.target)
        coincidentPoint = $node.data("snappedPoint")

        # if there is no 2nd point there is no coincident constraint
        return unless coincidentPoint?
        # create the coincident constraint (auto merging all previous coincident constraints)
        c = this.coincident
          points: [event.point, coincidentPoint]

      # before point move event listeners to synchronize attached points
      this.$svg.bind "beforemove", (event) =>
        return true unless event.triggerConstraints == true
        return true unless ( c = $(event.target).data("coincident") )?

        for p in c.points
          this.movePoint(p, event.x, event.y, false) unless event.point == p


    coincident: (opts) ->
      console.log "coincident created"
      defaults =
        points: []
      opts = $.extend defaults, opts
      opts.type = "coincident"

      # check for previous coincident constraints on the points and merge them
      for point in opts.points
        # check if the point has a pre-existing coincident constraint
        continue unless ( coincident = $(point.node).data "coincident" )?
        # if it does delete it and add it's points onto this coincident constraint
        for coincidentPoint in coincident.points
          opts.points.push coincidentPoint
          $node = $(coincidentPoint.node)
          $node.data "constraints", _.without( $node.data("constraints"), coincident )

      # the points list should contain no duplicates
      opts.points = _.unique opts.points

      # store the coincident constraint in the point's jquery data
      for p in opts.points
        $node = $(p.node)
        # each node has one or zero coincident constraints attached to it 
        # via it's coincident jquery data
        $node.data( "coincident", opts )
        # all constraints for each point are stored in the points constraints array
        constraints = [] unless ( constraints = $node.data("constraints") )?
        constraints.push opts
        $node.data( "constraints", constraints )

