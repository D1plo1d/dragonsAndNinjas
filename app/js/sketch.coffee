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
    console.log "init"
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
    console.log "Selected!"
    @unselect()
    console.log shape.$node
    @_selected = shape
    shape.$node.toggleClass("selected", true).trigger("select", shape)
    console.log shape.$node.attr("class")
    shape.element.toFront()

  unselect: ->
    return unless @_selected? 
    @_selected.$node.toggleClass("selected", false).trigger("unselect", @_selected)
    @_selected = null

  delete: -> if @_selected? then @_selected.delete()

  # Controller
  # ==================================
  _initController: ->
    console.log "init controller"
    this.element.mousedown => this.unselect()
    #this.$svg.draggable()

    this._mouseInit()
    #TODO: keyboard init will go here
    this._keyboardInit()

  # Keyboard interactions
  # -------------------------------

  _keyboardInit: ->
    $(document).bind "keyup", "del", => @delete()

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

