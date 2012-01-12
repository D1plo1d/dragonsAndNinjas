$ -> $.shape "text",
  parent: null
  numberOfPoints: 0
  raphaelType: "text"
  options:
    text: ""
    type: "explicit" # implicit = no drag + drop, externally controlled. explicit = drag + drop.
    $v: $V([0,0])


  _create: (ui) ->
      # TODO: ui create.. very similar to points
      @options.$v.elements = $V([@options.x, @options.y]).elements if @options.x? and @options.y?

      if ui == true
        @_initElement()
        @_afterCreate()

      @$node.bind "clickshape", @_clickElement

      # hack for parent shapes.. something should be done at the shape level to allow for child shapes
      @$node.hover (e) =>
        @parent.$node.toggleClass("hover", e.type == "mouseenter") if @parent? and @parent.$node?


  _ui: -> false


  _attrs: -> x: @options.$v.elements[0], y: @options.$v.elements[1], text: @options.text

  updateText: -> @element.attr text: @options.text


  move: ($v) ->
    @options.$v.elements = $v.elements
    @_updateTextField()
    @render()


  _clickElement: (e, $vMouse) ->
    @sketch.select(this)
    @sketch.updateSelection()
    return if @_$textField?
    @_$textField = $($("<input type='text' class='sketch-text-edit-field'></input>").appendTo("body"))
    @_$textField.attr("value", @options.text).focus()
    @$node.trigger "editstart", @_$textField
    @_$textField.bind "keyup", (e) => @_closeTextField() if e.which == 13
    @_updateTextField()


  _updateTextField: ->
    return unless @_$textField?
    $vPosition = $V [ @$node.attr("x"), @$node.attr("y") ]

    # todo: move this to an inverse camera matrix function in sketch
    top = @sketch.element.position().top
    $vPosition = $vPosition.subtract($V @sketch._zoom.positionOffset)
    $vPosition = $vPosition.add($V @sketch._position)
    $vPosition = $vPosition.x(1 / @sketch._zoom.positionMultiplier)
    $vPosition = $vPosition.add($V [0, top])


    for i, v of ([ ["width", -1], ["height", -1] ])
      $vPosition.elements[i] -= 0.5 * @$node[v[0]]() / @sketch._zoom.positionMultiplier
    @_$textField.css left: $vPosition.elements[0], top: $vPosition.elements[1]


  _updateSelection: ->
    @sketch._selected.push(@parent) if @parent? and _.include(@sketch._selected, @parent) == false


  _unselect: -> @_closeTextField()


  _closeTextField: ->
    return unless @_$textField?
    @options.text = @_$textField.attr "value"
    @$node.trigger "editend", @_$textField
    @_$textField.remove()
    @_$textField = null
    @render()


  _dragElement: (e, $vMouse) ->
    @$v.elements = $vMouse.elements if @options.type == "explicit"
    @$node.trigger("textdrag", $vMouse) if @$node?


  _afterDelete: () ->
    

