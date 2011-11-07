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
    @_created = ui == false

    # creates a new point and stores it in the points array if one does not already exist at the index i.
    loadPoint = (i) =>
      return if @points[i]?
      xyList = [ ["x#{i}", "y#{i}"] ]
      xyList.push(["x", "y"]) if i == 0
      # if the point is declared with x and y options instantiate it at [{x option value}, {y option value}]
      for xy in xyList
        pointOptions = type: "implicit", x: this.options[xy[0]], y: this.options[xy[1]]
        return @_addPoint(pointOptions) if pointOptions.x? and pointOptions.y?
      # if the point is undefined create it at [0,0]
      return @_addPoint( type: "implicit", x: 0, y: 0 )

    # create all the points if the object is pre-defined
    if ui == false and @numberOfPoints > 0
      loadPoint(i) for i in [0 .. @numberOfPoints-1]

    # predefined shape: set up the svg element
    @_initElement() unless ui == true

    # call the shape's create method with the ui flag for shape-specific intialization
    @_create(ui)

    # trigger the aftercreate event if the ui flag is false (otherwise we can't gaurentee the creation is complete)
    @_afterCreate() if ui == false


  # returns true if the shape is not fully defined and requiring gui interaction to fully define it.
  _ui: (options) -> options == false


  # signals the end of the shapes creation (asynchronously triggers the "aftercreate" event for gui interaction)
  _afterCreate: ->
    console.log "created #{@shapeType}"
    return unless @_created == false
    @dragging = false
    @$node.trigger("aftercreate", this)
    @_created = true


  # deletes the shape.
  delete: ->
    return if @_deleting == true
    # notifying listeners of this shapes untimely demise
    @$node.trigger( event = $.Event("delete", point: this) )
    return if event.isDefaultPrevented()

    @_deleting = true
    # delete any points that are deletable, ignore the ones that are still in use.
    point.delete() for point in @points

    # deleting the shape and any points it may have
    @element.remove()
    @$node.remove()
    @sketch._shapes = _.without(@sketch._shapes, this)
    @_afterDelete()

  _afterDelete: -> return null # custom deletion code goes here


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

    return point


  _initPointEvents: (point) ->
    # point move event listeners
    point.$node.bind "move", @_pointMoved

    # point deletion -> deletes this shape as well
    point.$node.bind "delete", => @delete()

    # point merging -> switch over to the new point
    point.$node.bind "merge", (e) =>
      index = _.indexOf(@points, e.deadPoint)
      return if index == -1
      @points[index] = e.mergedPoint
      @_initPointEvents( e.mergedPoint )


  _pointMoved: (e) =>
      @_afterPointMove(e.point) if @_afterPointMove?

      # update the element only if it and all it's points exist
      if @points.length == @numberOfPoints and @element?
        @element.attr @_attrs()
      return true


  # gets updated raphael attributes as a hash.
  # The attributes should be in the order as they are passed to the elements constructor.
  _attrs: -> throw "you need to overwride the _attrs function for your shape!"


  _dragElement: -> return true
  _dropElement: -> return true


  # sets this shapes element to a new element with given attributes (optional) and initializes its event listeners and properties
  _initElement: (attrs) ->
    # if no element exists, use the provide options or the _attr() method to generate attributes for a new element
    unless @element?
      attrs = @_attrs() unless attrs?
      @element = @sketch.paper[@raphaelType].apply( @sketch.paper, _.values( attrs ) )

    # move the shape behind the points
    this.element.toBack()

    # store the $node variable for the element
    @$node = $(@element.node)
    @$node = $(@$node).find("tspan") if @raphaelType == "text"
    @$node.addClass(this.shapeType)

    # drag and drop event listeners
    $svg = this.sketch.$svg
    $svg.bind "mousemove", (e) =>
      return true unless this.dragging == true

      top = this.sketch.element.position().top
      mouseV = $V([e.pageX - this.sketch._position[0], e.pageY - this.sketch._position[1] - top])

      this._dragElement(e, mouseV)

      return true

    this.$node.bind "mousedown", (e) =>
      return true unless @_created == true
      @dragging = true
      @sketch.select(this)
      return false

    $("body").bind "mouseup", (e) =>
      return true unless @dragging == true
      @dragging = false
      @_dropElement()
      return false


# Glue to bind shapes to sketches
$.shape = (shapeType, shapeHash) ->
  console.log("shapifying #{shapeType}")
  shapeHash.shapeType = shapeType

  # Wrapping the create method so that parameters are in a good format
  sketchExtension = {}
  sketchExtension["#{shapeType}"] = (options = false) -> new Shape(this, shapeHash, options)

  $.extend $.ui.sketch.prototype, sketchExtension

