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
    path: "M#{@points[0].attr('x')}, #{@points[0].attr('y')}L#{@points[1].attr('x')},#{@points[1].attr('y')}"


  _dragElement: (e, mouseVector) ->
    console.log "dragging"

