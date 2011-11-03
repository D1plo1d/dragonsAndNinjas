$ -> $.shape "line",
  numberOfPoints: 2
  raphaelType: "path"


  _create: (ui) ->
    return unless ui == true

    # create the first point and then display the line while positioning the second
    $(@_addPoint().node).one "aftercreate", =>
      @_addPoint()
      @_initElement()


  _attrs: ->
    path: "M#{points[0].x()}, #{points[0].y()}L#{points[1].x()},#{points[1].y()}"


  _dragElement: (e, mouseVector) ->
    console.log "dragging"

