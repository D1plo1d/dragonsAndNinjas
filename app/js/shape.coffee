###

Example Usage
------------------------------------------------------------
$.shape "myShapesName",
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
  numberOfPoints: 0
  dragging: false
  # The set of guide rapheal elements used in this shapes setup if ui = true.
  # TODO: deleted automatically on the "aftercreate" event
  guides: null

  # mixing in the specific shapes' methods and variables
  constructor: (shapeHash) ->
    _.extend(this, shapeHash)
    this[f] = $.proxy(this[f], this) for f in _.functions(this)


  _addGuide: (guideElement) ->
    @guides.push guideElement.hide()
    $(guideElement.node).addClass("creation-guide")
    return guideElement


  _addPoint: (point) ->
    # creating a point from a hash
    point = this.sketch.point(point) unless point.constructor.prototype == Raphael.el
    # pushing the point to the points array if it is not already in it
    @points.push point unless _.include(this.points, point)

    # point move event listeners
    $(point.node).bind "move", (e) =>
      @_afterPointMove(e.point)
      return true

    return point


  # sets this shapes element to the given element (optional) and initializes its event listeners and properties
  _initElement: (element) ->
    this.element = element if element?

    # move the shape behind the points
    this.element.toBack()

    # store the $node variable for the element
    this.$node = $(this.element.node).addClass(this.shapeType)

    # selection event listeners
    this.$node.click (e) => this.sketch.select(this.element)

    # drag and drop event listeners
    $svg = this.sketch.$svg
    $svg.bind "mousemove", (e) =>
      return true unless this.dragging == true

      top = this.sketch.element.position().top
      mouseV = $V([e.pageX - this.sketch._position[0], e.pageY - this.sketch._position[1] - top])

      this._dragElement(e, mouseV)

      return true
    this.$node.bind "mousedown", =>
      console.log "down"
      this.dragging = true
      return true
    $("body").bind "mouseup", =>
      this.dragging = false
      return true



$.shape = (shapeType, shapeHash) =>
  console.log("shapifying #{shapeType}")
  shapeHash.shapeType = shapeType

  # Wrapping the create method so that parameters are in a good format
  sketchExtension = {}
  sketchExtension["#{shapeType}"] = (opts = false) ->

    # true if the shape's parameters are not defined and thus we need to
    # build the object via the gui and user interaction
    ui = ( opts == false )

    # intializing the shape object and it's options
    shape = new Shape(shapeHash)
    shape.sketch = this
    shape.options = $.extend (points: []), shape.options, opts
    shape.points = shape.options.points
    shape.guides = this.paper.set()


    # creates a new point and stores it in the points array if one does not already exist at the index i.
    loadPoint = (i) ->
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
    if ui == false
      loadPoint.call(shape, i) for i in [0 .. shape.numberOfPoints-1]


    # call the shape's create method with the ui flag for shape-specific intialization
    shape._create(ui)


    # trigger the aftercreate event if the ui flag is false (otherwise we can't gaurentee the creation is complete)
    if ui == false then shape.$node.trigger("aftercreate", shape.element)

    return shape

  $.extend $.ui.sketch.prototype, sketchExtension

