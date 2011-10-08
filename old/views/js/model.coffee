$ -> $.fn.viewport = (key, value) ->
  data = $(this).data('viewport')
  svg = $(this).data('svg')
  $svg = $(this).find('svg')
  transform = $(this).data('svg-transform')


  # Element Creation Functions
  if key == "element.create"
    switch $(this).viewport('active-cmd')
      when 'line'
        line = svg.set()
        line.points = value
        line.selectedPoint = 1
        path = svg.path("M"+value[0][0]+" "+value[0][1]+"L"+value[1][0]+" "+value[1][1])
        line.push(path)
        line.path = path

        line.interaction_points = []

        i = 0
        for point in value
          line.push( line.interaction_points[i] = svg.circle(point[0], point[1], 2) )
          i++

        line.attr('stroke': "blue", 'fill': "blue", 'stroke-width': 1.3)
        transform.push(line)

        $(this).viewport('state', 'element.create-manipulate')
        $(this).viewport('selected-element', line)


  # All Other Functions
  else if typeof key == 'string'
    switch key

      # variable setters/getters
      when 'state', 'active-cmd', 'selected-element'
        if value?
          data[key] = value
        else
          return data[key]


      # Camera Model
      when 'camera.position'
        if value?
          $('.viewport').data('svg-transform').translate(
            value[0]-data.camera.position[0], value[1]-data.camera.position[1])
          data.camera.position = value
        else
          return data.camera.position

      when 'camera.rotation'
        if value?
          $('.viewport').data('svg-transform').rotate(value - data.camera.rotation)
          data.camera.rotation = value
        else
          return data.camera.rotation

      else
        throw 'Invalid viewport function called: ' + key



  # Constructor
  else

    # Setup the viewport data
    data =
      # state options: default, cmd.selected, element.create, element.create-manipulate element.manipulate, viewport.manipulate
      'state': 'default'
      'active-cmd': null
      'selected-element': null
      'mouse':
        'clicked': false # true if the mouse is currently clicked and/or dragging across the viewport
        # the last clicked position on the viewport
        # (relative to the design's coordinates, not the viewport position)
        'click-position': [0,0]
      'camera':
        'position': [0,0,0]
        'rotation': [0,0,1]

    $(this).data('viewport', data)

    # Init the svg
    svg = Raphael($(this)[0])
    transform = svg.set()
    $(this).data('svg', svg)
    $(this).data('svg-transform', transform)


    # adding the viewport controller and view (yes this is sloppy, why you gotta bring the hate?)
    this.viewportView().viewportController()

  # always return this for chaining by default
  return $(this)

