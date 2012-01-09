$ -> $.shape "text",
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

      @$node.click @_clickElement


  _ui: -> false


  _attrs: -> x: @options.$v.elements[0], y: @options.$v.elements[1], text: @options.text


  move: ($v) ->
    @options.$v.elements = $v.elements
    @_updateTextField()
    @render()


  _clickElement: (e) ->
    return if @_$textField?
    @_$textField = $($("<input type='text' class='sketch-text-edit-field'></input>").appendTo("body"))
    @_$textField.attr("value", @options.text).focus()
    @$node.trigger "editstart", @_$textField
    @_$textField.bind "keyup", (e) => @_closeTextField() if e.which == 13
    @_updateTextField()


  _updateTextField: ->
    return unless @_$textField?
    positions = @$node.offset()
    for position, v of (left: ["width", +1], top: ["height", -1])
      positions[position] = positions[position] + v[1]*( @$node[v[0]]() - @_$textField[v[0]]() ) /2
    @_$textField.css left: positions.left, top: positions.top


  _unselect: -> @_closeTextField()


  _closeTextField: ->
    return unless @_$textField?
    @options.text = @_$textField.attr "value"
    @$node.trigger "editend", @_$textField
    @_$textField.remove()
    @_$textField = null
    @render()


  _dragElement: (e, mouseVector) ->
    @$v.elements = mouseVector.elements if @options.type == "explicit"
    @$node.trigger("textdrag", mouseVector) if @$node?


  _afterDelete: () ->
    

