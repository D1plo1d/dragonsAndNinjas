$(document).bind "lastjs", ->
  # Main Menu
  # ===============================
  $cmdBar = $('.cmd-bar')
  cmdShape = null

  # Sketch Tab buttons (commands)
  $cmdBar.on 'click', '.cmd:not(.active, .disabled)', (e) =>
    $cmd = $(e.currentTarget)
    cmdShape = $('.sketch').sketch($cmd.attr('cmd'))

  # Click a button a second time to cancel the current action
  $cmdBar.on 'click', '.cmd.active', (e) =>
    $cmd = $(e.currentTarget)
    $cmd.removeClass("active")
    $('.sketch').sketch("cancel")
    return false

  # TODO: Unselect the command once it's action is finished or cancelled
  $('.sketch').on 'aftercreate beforedelete', (event) =>
    return true unless event.shape == cmdShape
    cmdShape = null
    $cmdBar.find('.cmd.active').removeClass('active')
    return true


  # Sketch
  # ===============================
  $('.sketch').sketch()

  # Context Menu
  # ===============================
  $context_menu = $('.sketch-context-menu').hide()

  $('.sketch').bind 'select', (e, selected) =>
    $context_menu.empty()
    return unless selected.length > 0
    for s in selected
      # load in the element's configuration html
      if s.shapeType? and s.shapeType == "arc"
        html = "
          <h4>Arc Direction</h4>
          <input type='checkbox' class='clockwise-arc-checkbox' /> Clockwise
        "
        $context_menu.html(html)

        # binding the config html to the selected objects properties
        $(".clockwise-arc-checkbox").prop("checked", s.direction() != 1).bind "click", (e) =>
          s.direction( if $(e.target).is(':checked') == false then 1 else 0 )
          return true

        # show the menu
        $context_menu.show "fade", "fast"
        return true

  $('.sketch').bind 'unselect', (e, element) =>
    $context_menu.hide "fade", "fast"




  # Demos
  # ===============================

###
  console.log "point?"
  for i in [0..100]
    $('.sketch').sketch('point', x: Math.random()*400, y: Math.random()*200)
    console.log "doing the point number #{i}"
  console.log "point!"


  console.log "line?"
  $('.sketch').sketch('line', x0: Math.random()*400, y0: Math.random()*200, x1: Math.random()*200, y1: Math.random()*200) for i in [0..5]
  console.log "line!"
###
