###

Example Usage
------------------------------------------------------------
$.shape "myShapesName",
  options: {} # a hash of the various options for your shape. options['points'] defaults to an empty array.

  # this will be where you store your shape's raphael element, do not create it here though! Do that in _create()!
  element: null

  _create: (ui) -> # initialization code goes here. UI flag denotes if the gui should be used to setup the shape.

  __afterPointMove: (point) -> # called after _create whenever a point in options['points'] is moved


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



# The shared prototype for all shapes
shapePrototype =
  # sets this shapes element and initializes its event listeners and properties
  _initElement: (element) ->
    this.element = element

    # move the shape behind the points
    this.element.toBack()

    # store the $node variable for the element
    this.$node = $(this.element.node).addClass(this.shapeType)

    # selection event listeners
    this.$node.click (e) => this.sketch.select(this.element)


  ###
  _createNextPoint: () ->
    
  ###



$.shape = (shapeType, shapeDefinition) =>
  console.log("shapifying #{shapeType}")


  # Wrapping the create method so that parameters are in a good format
  sketchExtension = {}
  sketchExtension["#{shapeType}"] = (opts = false) ->

    # true if the shape's parameters are not defined and thus we need to
    # build the object via the gui and user interaction
    ui = ( opts == false )

    # intializing the shape object and it's options
    shape = _.extend({shapeType: shapeType}, shapePrototype, shapeDefinition)
    shape.sketch = this
    shape.options = $.extend (points: []), shape.options, opts
    shape.points = shape.options.points

    # Points can be defined in the options by x/y coordinates as well as a simpler substitute
    # for passing previously defined points. If the points are definted via a series of x/y 
    # coordinates in the options, create points for each of the x#{i} and y#{i} options
    ###
    if ui == false
      addPoint = (optsX, optsY) =>
        point = this.point(type: "implicit", x: opts[optsX], y: opts[optsY])
        point.hide() if ui == true
        return point

      points = opts.points
      i = shape.points.length - 1

      shape.points = loop
        i++
        if opts["x#{i}"]? and opts["y#{i}"]?
          addPoint("x#{i}", "y#{i}")
        else if (i == 0 and opts["x"]? and opts["y"]?)
          addPoint("x", "y")
        else
          break
    ###

    # call the shape's create method with the ui flag for shape-specific intialization
    shape._create.call( shape, ui )

    # point move event listeners
    console.log shape.options.points
    for p in shape.options.points
      $(p.node).bind "move", (e) -> shape._afterPointMove.call(shape, e.point)

    # trigger the aftercreate event if the ui flag is false (otherwise we can't gaurentee the creation is complete)
    if ui == false then $node.trigger("aftercreate", element)

    return shape

  $.extend $.ui.sketch.prototype, sketchExtension

