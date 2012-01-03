class SketchExtension
  options: {}

  constructor: (@sketch, hash, options) ->
    # mix in this extension's functions and variables (overriding the default ones)
    _.extend(this, hash)
    this[f] = $.proxy(this[f], this) for f in _.functions(this)

    # options-based config
    @options = $.extend {}, @options, options

    @_create()

  _create: -> throw "you must override the _create method in your sketchExtension"

$.sketchExtension = (name, hash) ->
  # Wrapping the create method so that parameters are in a good format
  sketchExtension = {}
  sketchExtension["#{name}"] = (options = false) -> new SketchExtension(this, hash, options)

  $.extend $.ui.sketch.prototype, sketchExtension

