$ ->

  # Menu
  # ===============================
  $('#ribbon').ribbon(
    collapsible: false
    showTabsets: false
  )

  $('#ribbon .cmd').corner('round 5px').click ->
    if $(this).hasClass('active') then return
    $('.cmd').removeClass('active')
    $(this).toggleClass('active')
    $('.viewport').viewport('active-cmd', $(this).attr('cmd')).viewport('state', 'element.create')

  # Viewport
  # ===============================
  $('.viewport').viewport()

