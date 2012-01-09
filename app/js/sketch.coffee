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

  # Model
  # ==================================


  _create: ->
    this.paper = Raphael(this.element[0])
    this.root = this.paper.set()
    this.$svg = this.element.find("svg")
    this._initController()


  # sets the sketch's x,y position relative to the screen
  set_position: (position) ->
    this.paper.setViewBox(-position[0], -position[1], this.element.width(), this.element.height(), true)
    this._position = position


  # zooms the plane towards/away from the camera (- is towards the camera)
  zoom: (zoom) ->
    console.log "zoom"


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
    $(document).bind "keyup", "del", => @delete()
    $(document).bind "keyup", "esc", => @cancel()

    # TODO: move this to shape or line?
    @shift = false
    $(document).bind "keydown", "shift", => @shift = true
    $(document).bind "keyup", "shift", => @shift = false

    $(@$svg).bind "aftercreate", (e, shape) =>
      if @shift and shape.shapeType == "line"
        @line(points: [ shape.points[1] ])

  # Mouse interactions
  # -------------------------------

  _mouseStart: (e) ->
    this._dragging = $(e.target).is("svg")
    pos = this._position
    this._sketch_offset_click_pos =  [ e.pageX - pos[0], e.pageY - pos[1] ]


  _mouseDrag: (e) ->
    return true unless this._dragging == true
    # translate the sketch by [deltaX, deltaY]
    p = [e.pageX - this._sketch_offset_click_pos[0], e.pageY - this._sketch_offset_click_pos[1] ]
    this.set_position p

