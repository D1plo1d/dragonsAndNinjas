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

  # the currently selected element(s) of the sketch (or [] if none are selected)
  selected: []

  # the position of the sketch relative to the screen
  _position: [0,0]

  # the zoom model
  _zoom:
    value: 0
    defaultValue: 0
    defaultIncrement: 0.5
    mouseWheelIncrement: 0.25
    # the amount to multiply pixel movements of the mouse by to get zoom-relative sketch movements.
    # Calculated by _updateViewBox
    positionMultiplier: 1
    positionOffset: [0,0]

  # An array of all the points in the sketch
  _points: []
  # An array of all the shapes in the sketch
  _shapes: []


  # Model
  # ==================================


  _create: ->
    @paper = Raphael(this.element[0])
    @root = @paper.set()
    @$svg = @element.find("svg")
    @_initFullScreen()
    @_initController()
    @_updateViewBox()
    @_rescaleElementsToZoom()
    @_initIoBar()


  _initIoBar: ->
    @$ioBar = $(".title-bar").ioBar
      serialize: => @serialize("json")
      deserialize: (data) => @deserialize(data, "json")
      reset: => @reset()


  save: (fileName) -> @$ioBar.ioBar("save", fileName)
  load: (fileName) -> @$ioBar.ioBar("load", fileName)


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


  _rescaleElementsToZoom: () ->
    m = @_zoom.positionMultiplier
    # rescale all the lines to the new zoom
    $2pxElements = $("svg .line, .arc, .circle, .ellipse, .dimension .angle")
    $2pxElements.globalcss "stroke-width", 2 * m

    $guides = $("svg .creation-guide")
    $guides.globalcss "stroke-width", 1 * m
    $guides.globalcss "stroke-dasharray", "#{4 * m}, #{4 * m}"

    $explicitPoint = $("svg .explicit-point")
    $explicitPoint.globalcss "stroke-width", 1 * m
    $explicitPoint.globalcss "font-size", 29 * m


  _zoomChange: ->
    @._updateViewBox()
    @_rescaleElementsToZoom()
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
    @_selected = [] unless @_selected?
    #console.log @_selected
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
    @_selected = []
    @$svg.trigger("unselect")


  # every point belonging to another shape in the current selection
  _selectedChildPoints: -> _( s.points for s in @_selected ).chain().flatten().uniq().value()


  # every shape in the current selection except points belonging to another shape in the current selection
  _selectedParentShapes: -> _.difference( @_selected, @_selectedChildPoints() )


  cancel: ->
    #console.log "cancelling #{s.shapeType}" for s in @_selectedParentShapes()
    return unless @hasSelection()
    s.cancel() for s in @_selectedParentShapes()
    @updateSelection()
    @$svg.trigger("cancel")


  delete: ->
    return unless @hasSelection()
    s.delete() for s in @_selectedParentShapes()
    @unselect()


  serialize: (format = "yaml") ->
    console.log format
    meta = { version: "0.0.0 Mega-Beta" }
    shapes = _.compact( shape.serialize() for shape in @_shapes )
    serialization_hash = {meta: meta, shapes: shapes}

    return serialization_hash if format == "hash"

    serial_data = JSON.stringify(serialization_hash) if format == "json"
    serial_data = YAML.dump(serialization_hash) if format == "yaml"

    console.log serial_data
    return serial_data


  deserialize: (obj, format = "yaml") ->
    #hash
    hash = obj if format == "hash"

    # yaml
    # TODO: none of these fucking yaml parsers work. what the hell js?
    hash = jsyaml.load(obj) if format == "yaml"
    #console.log(hash = YAMLParser.eval(obj)) if format == "yaml"
    require.config
      baseUrl: "/lib/require-js/"
    #hash = require( ["yaml"], (yaml) -> yaml.eval(obj) ) if format == "yaml"

    # json
    hash = JSON.parse(obj) if format == "json"


    # TODO: reset the sketch's content before loading in the new shapes
    @reset()

    #console.log hash.shapes
    # TODO: load in each object and stuffs
    for i, opts of hash.shapes
      shapeType = opts.shapeType
      #console.log shapeType
      this[shapeType](opts)


  reset: ->
    @resetZoom()
    console.log "before reset"
    console.log @_shapes.length
    for shape in @_shapes
      shape.delete()
    console.log "reset"
    console.log @_shapes.length
    console.log @_points.length
    console.log "reset end"



  # sets up window resize events and does an initial resize of the sketch to fit the screen.
  _initFullScreen: ->
    $(window).resize _.debounce ( => @_resizeWindow() ), 40
    @_resizeWindow()


  # listener for window resize events. Resizes the svg and then updates the sketch's scaling.
  _resizeWindow: ->
    $window = $(window)
    height = $window.height() - @element.offset().top
    @$svg.attr
      width: $window.width()
      height: if height > 0 then height else 0

    @_updateViewBox()


  # Controller
  # ==================================
  _initController: ->

    this.element.mouseup   (e) => $(e.target).trigger "sketchmouseup",   @_$vMouse(e)
    this.element.mousedown (e) => $(e.target).trigger "sketchmousedown", @_$vMouse(e)
    this.element.mousemove (e) => $(e.target).trigger "sketchmousemove", @_$vMouse(e)

    this.element.bind "sketchmousedown", => @unselect()
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

    # New
    $(document).bind "keydown", "ctrl+n", (e) =>
      @reset()
      e.stopPropagation( )  
      e.preventDefault( )
      return false

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

    $(@$svg).bind "aftercreate", (e) =>
      if @shift and e.shape.shapeType == "line"
        @line(points: [ e.shape.points[1] ])

  # Mouse interactions
  # -------------------------------

  # Calculates a sketch-relative position vector for mouse events accounting for translation and scaling
  _$vMouse: (e) ->
    top = @element.position().top
    # Determining if e is a jQuery Event object or a Raphael Vector object
    $vMouse = if e.target? then $V([e.pageX, e.pageY]) else e

    $vMouse = $vMouse.subtract($V [0, top])
    $vMouse = $vMouse.x(@_zoom.positionMultiplier)
    $vMouse = $vMouse.subtract($V @_position)
    $vMouse = $vMouse.add($V @_zoom.positionOffset)

  _mouseWheel: (event, delta, deltaX, deltaY) ->
    @zoom( @_zoom.mouseWheelIncrement * delta )
    event.preventDefault()
    return true

  _mouseStart: (e) ->
    @_dragging = $(e.target).is("svg")
    @_$vSketchClick =  @_$vMouse(e)


  _mouseDrag: (e) ->
    return true unless @_dragging == true
    # translate the sketch by [deltaX, deltaY]
    p = @_$vMouse(e).subtract(@_$vSketchClick).add($V @_position)
    @set_position p.elements

