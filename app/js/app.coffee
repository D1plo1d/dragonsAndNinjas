$(document).bind "lastjs", ->
  # Main Menu
  # ===============================
  $('#ribbon').ribbon
    collapsible: false
    showTabsets: false


  $('#ribbon .cmd').corner('round 5px').click ->
    if $(this).hasClass('active') then return
    $('.cmd').removeClass('active')
    $(this).toggleClass('active')
    $('.viewport').viewport('active-cmd', $(this).attr('cmd')).viewport('state', 'element.create')

  # Sketch
  # ===============================
  console.log "sketch?"
  $('.sketch').sketch()
  console.log "sketch!"

  # Context Menu
  # ===============================
  $context_menu = $('.sketch-context-menu').hide()

  $('.sketch').bind 'select', (e, element) =>
    $context_menu.find(".elements").html("#{$(element.node).attr('class')} ##{element.id}")

    constraints_html = ""
    if ( constraints = $(element.node).data('constraints') )?
      console.log constraints
      constraints_html += "<li>#{c.type}</li>" for c in constraints

    $context_menu.find(".constraints").html("<ul>#{constraints_html}</ul>")
    $context_menu.show "slide", direction: "left"

  $('.sketch').bind 'unselect', (e, element) =>
    $context_menu.hide "slide", direction: "left"

  # Demos
  # ===============================

  console.log "point?"
  $('.sketch').sketch('point', x: Math.random()*400, y: Math.random()*200) for i in [0..10]
  console.log "point!"


  console.log "line?"
  $('.sketch').sketch('line', x0: Math.random()*400, y0: Math.random()*200, x1: Math.random()*200, y1: Math.random()*200) for i in [0..5]
  console.log "line!"

