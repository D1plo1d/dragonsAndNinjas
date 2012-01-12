# Enables scrolling and zooming for an SVG element created inside the selected element. Also delegates click events to child elements (if we even need this..[?])
$.widget "ui.sketch", $.ui.mouse,
  options: {}

  # Private Variables
  # ==================================

  # the svg jquery element
  $svg: null
  # the raphael paper object containing the svg element containing the root set
  paper: null
  # the set containing all other sets and elements in the sketch
  root: null

  # the currently selected element of the sketch (or null if none are selected)
  selectedElement: null

  # the position of the sketch relative to the screen
  _position: [0,0]

  # the zoom model
  _zoom:
    value: 0
    defaultValue: 0
    defaultIncrement: 1
    mouseWheelIncrement: 0.5
    # the amount to multiply pixel movements of the mouse by to get zoom-relative sketch movements.
    # Calculated by _updateViewBox
    positionMultiplier: 1
    positionOffset: [0,0]

  # Model
  # ==================================


  _create: ->
    @paper = Raphael(this.element[0])
    @root = @paper.set()
    @$svg = @element.find("svg")
    @_initController()
    @_updateViewBox()


  # inner method for reconfiguring the zoom port when the position or zoom changes
  _updateViewBox: ->
    @_zoom.positionMultiplier = Math.pow( 2, -1 * @_zoom.value )
    outerDimensions = ( @element[d]() for d in ["width", "height"] )
    viewportDimensions = ( d*@_zoom.positionMultiplier for d in outerDimensions )
    @_zoom.positionOffset = (outerDimensions[i]/2 - viewportDimensions[i]/2  for i in [0, 1])
    center = ( -1 * @_position[i] + @_zoom.positionOffset[i] for i in [0,1] )
    @paper.setViewBox(center[0], center[1], viewportDimensions[0], viewportDimensions[1], true)
  

  # sets the sketch's x,y position relative to the screen
  set_position: (position) ->
    @_position = position
    @_updateViewBox()


  # zooms the plane towards/away from the camera (- is towards the camera)
  zoom: (zoom) -> # zoom = ++ or -- or a number to increment the current zoom by.
    if zoom == "++" or zoom == "--"
      @_zoom.value += (if zoom == "++" then +1 else -1) * @_zoom.defaultIncrement
    else
      @_zoom.value += zoom
    @_zoomChange()

  # sets the zoom to a absolute position (not relative to the previous zoom) or the default if 
  # zoom is undefined
  resetZoom: (zoom) ->
    @_zoom.value = (if zoom? then zoom else @_zoom.defaultValue)
    @_zoomChange()


  _zoomChange: ->
    @._updateViewBox()
    @$svg.trigger("zoomchange")


  # element selection
  select: (shape) ->
    if @hasSelection()
      # if the element is included in the selected shapes maintain the current selection
      return true if _.include(@_selected, shape)
      # prevent selection if the current shape creation is not complete
      return false unless s._created == true for s in @_selected
      # kill the previous selections
      @unselect()

    @_selected = [shape]
    @updateSelection()

    @$svg.trigger("select", [@_selected])
    return true


  hasSelection: () -> @_selected? and @_selected.length > 0

  updateSelection: () ->
    @_selected = _.uniq( _.union( @_selected, @_selectedChildPoints() ) )
    for s in @_selected
      s.$node.toggleClass("selected", true) if s.$node?
      s._updateSelection()
      s.element.toFront() if s.element?


  unselect: ->
    return unless @hasSelection()
    @cancel()
    for s in @_selected
      s.$node.toggleClass("selected", false) if s.$node?
      s._unselect()
    @_selected = null
    @$svg.trigger("unselect")


  # every point belonging to another shape in the current selection
  _selectedChildPoints: -> _( s.points for s in @_selected ).chain().flatten().uniq().value()


  # every shape in the current selection except points belonging to another shape in the current selection
  _selectedParentShapes: -> _.difference( @_selected, @_selectedChildPoints() )


  cancel: ->
    console.log "cancelling #{s.shapeType}" for s in @_selectedParentShapes()
    return unless @hasSelection()
    s.cancel() for s in @_selectedParentShapes()
    @updateSelection()
    @$svg.trigger("cancel")


  delete: ->
    return unless @hasSelection()
    s.delete() for s in @_selectedParentShapes()
    @unselect()

  # Controller
  # ==================================
  _initController: ->
    this.element.mousedown => this.unselect()
    #this.$svg.draggable()

    this._mouseInit()
    #TODO: keyboard init will go here
    this._keyboardInit()

  # Keyboard interactions
  # -------------------------------

  _keyboardInit: ->
    # Delete and Cancel
    $(document).bind "keyup", "del", => @delete()
    $(document).bind "keyup", "esc", => @cancel()

    # Zoom
    $(document).bind "keypress", "+", =>
      @zoom("++")
      return false
    $(document).bind "keypress", "-", =>
      @zoom("--")
      return false
    @$svg.mousewheel _.throttle ( (a,b,c,d) => @_mouseWheel(a,b,c,d) ), 20


    # TODO: move this to shape or line?
    @shift = false
    $(document).bind "keydown", "shift", => @shift = true
    $(document).bind "keyup", "shift", => @shift = false

    $(@$svg).bind "aftercreate", (e, shape) =>
      if @shift and shape.shapeType == "line"
        @line(points: [ shape.points[1] ])

  # Mouse interactions
  # -------------------------------

  _mouseWheel: (event, delta, deltaX, deltaY) ->
    @zoom( @_zoom.mouseWheelIncrement * delta )
    event.preventDefault()
    return true

  _mouseStart: (e) ->
    @_dragging = $(e.target).is("svg")
    pos = @_position
    @_sketch_offset_click_pos =  [ e.pageX*@_zoom.positionMultiplier - pos[0], e.pageY*@_zoom.positionMultiplier - pos[1] ]


  _mouseDrag: (e) ->
    return true unless @_dragging == true
    # translate the sketch by [deltaX, deltaY]
    p = [e.pageX*@_zoom.positionMultiplier - @_sketch_offset_click_pos[0], e.pageY*@_zoom.positionMultiplier - @_sketch_offset_click_pos[1] ]
    @set_position p

