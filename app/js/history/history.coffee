$.extend $.ui.sketch.prototype,
  _history: []
  _future: []


  _initHistory: ->
    console.log("init history")
    @$svg.bind "beforeCreate afterCreate beforeDrag afterDrop", (e, shape) =>
      @_pushToHistory(e.type, shape)


  # when a new event is recorded add it to the history and clear the future (clear the redos)
  _pushToHistory: (eventType, shape) ->
    @_future = []
    event = eventType: eventType, target: shape,
    # Clone the position vector for posterity if it is a point and this is a movement event
    if shape.shapeType == "point" and _.include(["beforeDrag", "afterDrop"], eventType)
      event.$v = shape.$v.x(1)
    @_history.push event


  _popFromHistory: ->
    @_future.push( event = @_history.pop() )
    return event

  _popFromFuture: ->
    @_history.push( event = @_future.pop() )
    return event


  undo: ->
    console.log("undo")

    switch event = @_popFromHistory()
      #TODO: a more robust way of finding the drag event that prompted the drop event.
      # What if it wasn't the previous event?
      when "afterDrop"
        event = @_popFromHistory()
        event.target.move(event.$v) if (event.shapeType = "point")
      when "afterCreate", "beforeCreate"
        # if it is a implicit point rewind the shape's creation to creating that Nth point
        if event.shapeType = "point"
          console.write("point")
        else
          event.target.delete()

  redo: ->
    console.log("redo")

    switch event = @_popFromFuture()
      #TODO: a more robust way of finding the drag event that prompted the drop event.
      # What if it wasn't the previous event?
      when "afterDrop"
        event = @_popFromHistory()
        event.target.move(event.$v) if (event.shapeType = "point")
      # TODO: all this fucking redo shit
