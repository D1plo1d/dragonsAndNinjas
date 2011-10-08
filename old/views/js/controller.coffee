$ -> $.fn.viewportController = () ->
  svg = $(this).data('svg')
  $svg = $(this).find('svg')
  transform = $(this).data('svg-transform')


  # Mouse bindings
  $svg.mousedown (e) =>
    pos = $(this).viewport('camera.position')

    offset = $(this).offset()
    screen_pos = [e.pageX - offset.left, e.pageY - offset.top]

    m = $(this).data('viewport')['mouse'] =
      'click-position': [ e.pageX - pos[0], e.pageY - pos[1] ]
      'clicked': true

    console.log($(this).viewport('state'))
    switch $(this).viewport('state')
      when 'element.create'
        switch $(this).viewport('active-cmd')
          when 'line'
            $(this).viewport('element.create', [screen_pos, screen_pos])


  $svg.mousemove (e) =>
    mouseData = $(this).data('viewport')['mouse']
    if mouseData['clicked'] == false then return

    offset = $(this).offset()
    scroll_pos = mouseData['click-position']

    scroll_pos = [ e.pageX - scroll_pos[0], e.pageY - scroll_pos[1] ]
    screen_pos = [e.pageX - offset.left, e.pageY - offset.top]

    element = $(this).viewport('selected-element')

    switch $(this).viewport('state')
      when 'element.create' then return

      when 'element.manipulate', 'element.create-manipulate'
        switch $(this).viewport('active-cmd')

          when 'line'
            path = element.path

            p = element.points
            selected = element.selectedPoint
            p[selected] = screen_pos
            element.points = p

            path.attr('path', "M"+p[0][0]+" "+p[0][1]+"L"+p[1][0]+" "+p[1][1])

            interp = element.interaction_points
            for i in [0..1]
              interp[i].attr
                'cx': p[i][0]
                'cy': p[i][1]

      # default: move/rotate the viewport
      else $(this).viewport('camera.position', scroll_pos)


  $(document).mouseup =>
    if ($(this).data('viewport')['mouse']['clicked'] == false) then return
    $(this).data('viewport')['mouse']['clicked'] = false
    switch $(this).viewport('state')
      when 'element.create-manipulate'
        $(this).viewport('state', 'element.create')
      when 'element.manipulate'
        $(this).viewport('state', 'default')
    console.log($(this).viewport('state'))



  # Keyboard Controller
  
  $(document).keyup (event) =>
    switch event.which
      when 27 then $(this).viewport('state', 'default') # ESC

