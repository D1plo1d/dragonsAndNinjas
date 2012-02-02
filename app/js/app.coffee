$(document).bind "lastjs", ->
  # Main Menu
  # ===============================
  $cmdBar = $('.cmd-bar')
  $("a[href='#ribbonTabSketch']").click()

  # Sketch Tab buttons (commands)
  $cmdBar.find('.cmd').click (e) =>
    if $(e.target).hasClass('active') or $(e.target).hasClass('disabled') then return
    $('.sketch').sketch($(e.target).attr('cmd'))

  # Click a button a second time to cancel the current action
  $cmdBar.on 'click', '.cmd.active', (e) =>
    $(e.target).removeClass("active")
    $('.sketch').sketch("cancel")
    return false

  # TODO: Unselect the command once it's action is finished or cancelled
  #$('.sketch').bind 'aftercreate cancel', (event) =>
  #  $cmdBar.find('.active').removeClass('active')

  # File Tab buttons
  #--------------------------------
  #$('#load-modal').modal("hide")
  #$('#save-as-modal').modal("hide")

  $(".file-new").click -> $('.sketch').sketch("reset")


  # Selecting a file to load (in the load modal)
  $(document).on "click", ".load-file-list .nav.nav-list li:not('.nav-header')", (e) ->
    $item = $(this)
    $list = $item.closest(".nav.nav-list")
    $list.find("li").removeClass("active")
    $item.addClass("active")

  # Selecting a file to save over (in the save as modal)
  $(document).on "click", ".save-as-file-list .nav.nav-list li:not('.nav-header')", (e) ->
    $item = $(this)
    $item.closest(".modal-body").find(".file-name-input").val $item.data("file-name")


  # The load and save modal templates
  loadTemplate = Handlebars.compile $("#load-modal-template").html()
  saveAsTemplate = Handlebars.compile $("#save-as-modal-template").html()

  # Finishing the open transaction or displaying an error
  $(document).on "click", ".open-btn", (e) ->
    $modal = $(this).closest(".modal")
    filename = $modal.find("li.active").data("file-name")
    console.log "opening '#{filename}'"
    #$('.sketch').sketch("load", filename)
    $modal.modal("hide")

  # Finishing the save as transaction or displaying an error
  $(document).on "click", ".save-as-btn", (e) ->
    $modal = $(this).closest(".modal")
    filename = $modal.find(".file-name-input").val()
    console.log "saving as '#{filename}'"
    #$('.sketch').sketch("save", filename)
    $modal.modal("hide")

  # Opening the open modal
  $(".file-open").click ->
    # TODO: file lists in sketch-files-module with persist.js
    #data = 
    data = {files: ["my cad file 1","another cad file b","a way better file c"]}
    $('#load-modal').html(loadTemplate(data)).addClass("modal").modal()

  # Opening the save as modal
  $(".file-save").click ->
    data = {files: ["my cad file 1","another cad file b","a way better file c"]}
    $('#save-as-modal').html(saveAsTemplate(data)).addClass("modal").modal()


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
