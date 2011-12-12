$(document).bind "lastjs", ->
  # Main Menu
  # ===============================
  $('#ribbon').ribbon
    collapsible: false
    showTabsets: false

  $ribbon = $('#ribbon')
  $ribbon.find('.cmd').corner('round 5px').click (e) =>
    if $(e.target).hasClass('active') or $(e.target).hasClass('disabled') then return
    #$('.cmd').removeClass('active')
    #$(e.target).toggleClass('active')
    $('.sketch').sketch($(e.target).attr('cmd'))

  #$('.sketch').bind 'aftercreate cancel', (event) =>
  #  $ribbon.find('.active').removeClass('active')

  # Sketch
  # ===============================
  console.log "sketch?"
  $('.sketch').sketch()
  console.log "sketch!"

  # Context Menu
  # ===============================
  $context_menu = $('.sketch-context-menu').hide()

  $('.sketch').bind 'select', (e, selected) =>
    $context_menu.empty()
    console.log selected
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

  # Legacy codes
  ###
  constraintsHtml =  ->
    constraints_html = ""
    if ( constraints = $(element.node).data('constraints') )?
      console.log constraints
      constraints_html += "<li>#{c.type}</li>" for c in constraints
  ###


  # Save
  # ===============================

  # todo
  ###Downloadify.create('downloadify',{
    filename: function(){
      return document.getElementById('filename').value;
    },
    data: function(){ 
      return document.getElementById('data').value;
    },
    onComplete: function(){ 
      alert('Your File Has Been Saved!'); 
    },
    onCancel: function(){ 
      alert('You have cancelled the saving of this file.');
    },
    onError: function(){ 
      alert('You must put something in the File Contents or there will be nothing to save!'); 
    },
    swf: 'media/downloadify.swf',
    downloadImage: 'images/download.png',
    width: 100,
    height: 30,
    transparent: true,
    append: false
  });###


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
