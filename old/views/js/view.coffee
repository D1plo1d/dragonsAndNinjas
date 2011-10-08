$ -> $.fn.viewportView = () ->
  # Rounded Corners
  $viewport = $('.viewport').corner('round 5px')
  # Height
  $viewport.height($(window).height() - $viewport.offset().top - parseInt($viewport.css('margin-bottom')))

  $viewport.find('svg').height($viewport.innerHeight())
  return $(this)


