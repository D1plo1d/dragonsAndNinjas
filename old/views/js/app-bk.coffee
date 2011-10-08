$ ->

  # Menu View
  # ===============================
  $('#ribbon').ribbon(
    collapsible: false
    showTabsets: false
  )

  # Viewport View
  # ===============================
  # Rounded Corners
  $viewport = $('.viewport').corner('round 5px')
  # Height
  $viewport.height($(window).height() - $viewport.offset().top - parseInt($viewport.css('margin-bottom')))

  # Viewport Model
  # ===============================
  $('.viewport').data('state', 'default')


  # Sketchplain Model/Controller
  # ===============================
  $sketchplain = $('.sketch-plain')

  # Scrolling
  $sketchplain.mousedown (e) ->
    pos = $(this).children('g').data('sketch-pos') || [0,0]
    $(this).data('click-start-pos', [e.pageX - pos[0], e.pageY - pos[1]])

  $sketchplain.mousemove (e) ->
    if (pos = $(this).data('click-start-pos'))?
      pos = [e.pageX - pos[0], e.pageY - pos[1]]
      
      $(this).children('g').data('sketch-pos', pos).attr('transform', 'translate('+pos[0]+','+pos[1]+') rotate(0)')
#      $(this).css('top', e.pageY - pos[1])

  $sketchplain.mouseup -> $(this).data('click-start-pos', null)

  # Picking


  # Menu Controller
  # ===============================

  $('.cmd').click ->
    state = $('.viewport').data('state', 'cmd.selected')

#  $('
#    switch $(this).attr('cmd')
#      when "line" then state = 'cmd.selected'

  $sketchplain_g = $('.sketch-plain').children('g')
  

