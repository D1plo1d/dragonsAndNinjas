$(document).bind "lastjs", ->
  # Main Menu
  # ===============================
  $('#ribbon').ribbon
    collapsible: false
    showTabsets: false

  cmdElement = null

  $ribbon = $('#ribbon')
  $ribbon.find('.cmd').corner('round 5px').click (e) =>
    if $(this).hasClass('active') or $(e.target).hasClass('disabled') then return
    $('.cmd').removeClass('active')
    $(e.target).toggleClass('active')
    cmdElement = $('.sketch').sketch($(e.target).attr('cmd'))
    $(e.target).attr('cmd')

  $('.sketch').bind 'aftercreate', (event, element) =>
    return true unless cmdElement == element
    cmdElement = null
    $ribbon.find('.active').removeClass('active')

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
