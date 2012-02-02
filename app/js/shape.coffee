###

Example Usage
------------------------------------------------------------
$ -> $.shape "myShapesName",
  numberOfPoints: 2
  options: {} # a hash of the various options for your shape. options['points'] defaults to an empty array.

  # this will be where you store your shape's raphael element, do not create it here though! Do that in _create()!
  element: null

  _create: (ui) -> # initialization code goes here. UI flag denotes if the gui should be used to setup the shape.

  _afterPointMove: (point) -> # called after _create whenever a point in options['points'] is moved


Predefined methods (for your convenience):
------------------------------------------------------------

  _initElement(element)
    - sets this shapes element and initializes its event listeners and properties

Shape Events
------------------------------------------------------------
All shape events are triggered on the shapes $node element.

  "aftercreate"
    - called after the shape is created
    - called automatically when ui = false
    - make sure to trigger this after setup when ui = true, $.shape will not do that for you!

###



# The shared class for all shapes
class Shape
  options: {}
  numberOfPoints: 0
  # The set of guide rapheal elements used in this shapes setup if ui = true.
  # TODO: deleted automatically on the "aftercreate" event
  guides: null
  dragging: false
  raphaelType: ""


  constructor: (@sketch, shapeHash, options) ->
    # mix in this shape's functions and variables (overriding the default ones)
    _.extend(this, shapeHash)
    this[f] = $.proxy(this[f], this) for f in _.functions(this)

    # options-based shape config
    @options = $.extend (points: []), @options, options
    @points = @options.points
    @guides = @sketch.paper.set()

    # true if the shape's parameters are not defined and thus we need to
    # build the object via the gui and user interaction
    ui = @_ui( options )
    @_created = false

    @sketch.$svg.trigger("beforeCreate", this)

    # select all newly created shapes by default unless it is an implicit point
    # (in which case it will automatically be included in it's parent shapes' selection array)
    @sketch.select(this) unless this.options.type == "implicit"

    # initializes a predefined point at index i if one exists
    loadPoint = (i) =>
      # initialize the points events and return if it already exists
      return @_addPoint(@points[i]) if @points[i]?
      # otherwise try and create it from x and y options
      xyList = [ ["x#{i}", "y#{i}"] ]
      xyList.push(["x", "y"]) if i == 0
      # if the point is declared with x and y options instantiate it at [{x option value}, {y option value}]
      for xy in xyList
        pointOptions = type: "implicit", x: this.options[xy[0]], y: this.options[xy[1]]
        return @_addPoint(pointOptions) if pointOptions.x? and pointOptions.y?
      # if the point is undefined leave it for interactive setup

    # setup each predefined point
    if @numberOfPoints > 0
      loadPoint(i) for i in [0 .. @numberOfPoints-1]

    # call the shape's create method with the ui flag for shape-specific intialization
    @_create(ui)

    # predefined shape: set up the svg element
    @_initElement() unless ui == true

    # trigger the aftercreate event if the ui flag is false (otherwise we can't gaurentee the creation is complete)
    @_afterCreate() if ui == false


  _ui: (options) -> @_has_points(options)


  # returns true if the shape is not fully defined and requiring gui interaction to fully define it.
  _has_points: (options) ->
    return true if options == false

    # points can be defined with x and y options
    return false if options["x"]? and options["y"]? and @numberOfPoints == 1

    return false if options.points? and options.points.length == @numberOfPoints

    # multi-point shapes need each x0, y0, x1, y1.. to be defined
    for i in [0..@numberOfPoints - 1]
      return true unless ( options["x#{i}"]? or options["y#{i}"]? )
    return false


  # signals the end of the shapes creation (asynchronously triggers the "aftercreate" event for gui interaction)
  _afterCreate: ->
    return if @_created == true
    #console.log "created #{@shapeType}"
    @dragging = false
    @_created = true
    @sketch._shapes.push( this )
    @$node.trigger("aftercreate", this)


  # cancels the current operation on this shape (if any)
  cancel: () ->
    @delete() if @_created == false


  # deletes the shape. targetShape: the shape that was deleted that started this deletion chain.
  delete: (targetShape = this) ->
    return if @_deleting == true
    # notifying listeners of this shapes untimely demise if the node is created
    if @$node?
      @$node.trigger( event = $.Event("beforedelete", targetShape: targetShape) )
      return if event.isDefaultPrevented()

    #console.log "deleting #{@shapeType}"
    @_deleting = true
    # delete any points that are deletable, ignore the ones that are still in use.
    point.delete(targetShape) for point in @points

    # deleting the shape and any points it may have
    @element.remove() if @element?
    @$node.remove() if @$node?
    @sketch._shapes = _.without(@sketch._shapes, this)
    @_afterDelete()

  _afterDelete: -> return null # custom deletion code goes here

  isDeleted: -> return @_deleting == true

  # adds and and initializes a guide (a graphical element for shape constructing purposes) to this shape
  _addGuide: (guideElement) ->
    @guides.push guideElement
    $(guideElement.node).addClass("creation-guide")
    return guideElement


  # adds a point to this shape.
  # _addPoint() defaults to a implicit point, a hash or point can also be passed to override this default.
  _addPoint: (point = type: "implicit") ->
    # creating a point from a hash
    point = @sketch.point(point) if point.type?

    # pushing the point to the points array if it is not already in it
    @points.push point unless _.include(this.points, point)

    @_initPointEvents(point)

    # if this shape is selected style the newly added point appropriately
    @sketch.updateSelection()

    return point


  _initPointEvents: (point) ->
    # point move event listeners
    point.$node.bind "move", @_pointMoved

    # point deletion -> deletes this shape as well
    point.$node.bind "beforedelete", @_pointBeforeDelete

    # point merging -> switch over to the new point
    point.$node.bind "merge", (e) =>
      index = _.indexOf(@points, e.deadPoint)
      return if index == -1
      @points[index] = e.mergedPoint
      @_initPointEvents( e.mergedPoint )


  _pointBeforeDelete: (e) =>
    return true if @_deleting == true
    # if a point of this shape is the original target of a deletion delete this shape
    if _.include(@points, e.targetShape)
      @delete()
      return true
    # if the original target of deletion is a unrelated shape containing a shared point then 
    # prevent the shared point from being deleted, it is still required by this shape.
    return false


  _pointMoved: (e) =>
      @_afterPointMove(e.point) if @_afterPointMove?

      # update the element only if it and all it's points exist
      if @points.length == @numberOfPoints and @element?
        @render()
      return true


  render: ->
    @element.attr @_attrs() if @_elementInitialized == true


  # gets updated raphael attributes as a hash.
  # The attributes should be in the order as they are passed to the elements constructor.
  _attrs: -> throw "you need to overwride the _attrs function for your shape!"


  _dragElement: -> return true
  _dropElement: -> return true


  _unselect: -> null
  _updateSelection: -> null


  # sets this shapes element to a new element with given attributes (optional) and initializes its event listeners and properties
  _initElement: (attrs) ->
    return if @_elementInitialized == true
    @_elementInitialized = true
    # if no element exists, use the provide options or the _attr() method to generate attributes for a new element
    unless @element?
      attrs = @_attrs() unless attrs?
      @element = @sketch.paper[@raphaelType].apply( @sketch.paper, _.values( attrs ) )

    # move the shape behind the points
    this.element.toBack()

    # store the $node variable for the element
    @$node = $(@element.node)
    @$node = $(@$node).find("tspan") if @raphaelType == "text" and this.shapeType == "point"
    @$node.addClass(this.shapeType)

    # drag and drop event listeners
    $svg = this.sketch.$svg
    $svg.bind "sketchmousemove", (e, $vMouse) =>
      return true unless @dragging == true
      @_dragElement(e, $vMouse)
      return true

    # if this shape is selected style it appropriately
    @sketch.updateSelection()


    this.$node.bind "sketchmousedown", (e, $vMouse) =>
      return true unless @_created == true
      # prevent drag and drop if we are unable to select this shape
      return true unless @sketch.select(this)
      @dragging = true
      # wait 100ms to see if this is a click or a drag.
      _.delay @_delayedMouseDown, 100, $vMouse
      return false


    # ignore mouse downs if we are dragging the element
    # (so that we can click to place it and not accidently trigger svg dragging)
    @sketch.$svg.bind "sketchmousedown", (e, $vMouse) => return @dragging != true

    @sketch.$svg.bind "sketchmouseup", (e, $vMouse) =>
      return true unless @dragging == true
      @dragging = false
      @_dropElement()
      @$node.trigger("afterDrop", this) if @$node?
      return false


  _delayedMouseDown: ($vMouse) ->
    if @dragging == true
      @$node.trigger("beforeDrag", this) if @$node?
    else
      @$node.trigger "clickshape", $vMouse


  # Serializes this shape into a hash. Uses the _serialize to allow for shape-specific serialization.
  # By default this includes the object's points and options hash
  # (removing any x, y and points entries and replacing them with the shapes point array)
  # format: { options: {OBJECT_OPTIONS AND points: @points} }
  serialize: ->
    obj_hash = {shapeType: @shapeType}
    # excluding the intial point values (because we're going to replace these with values from @points)
    for key, value of @options
      obj_hash[key] = value unless /x[0-9]?/.exec(key) == key or key == "points"
    # injecting the current point positions as x,y options
    if @points? and @points.length > 0
      for index, point of @points
        obj_hash["#{axis}#{index}"] = point.$v.elements[axis_index] for axis_index, axis of ["x", "y"]
    # injecting non-standard attributes into the options hash
    return @_serialize(obj_hash)


  _serialize: (obj_hash) -> obj_hash



# Glue to bind shapes to sketches
$.shape = (shapeType, shapeHash) ->
  #console.log("shapifying #{shapeType}")
  shapeHash.shapeType = shapeType

  # Wrapping the create method so that parameters are in a good format
  sketchExtension = {}
  sketchExtension["#{shapeType}"] = (options = false) -> new Shape(this, shapeHash, options)

  $.extend $.ui.sketch.prototype, sketchExtension

