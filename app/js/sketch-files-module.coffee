# This deals with the task of importing files, exporting files, saving and loading
# It is not included in sketch because it's not really core to sketching.
$ -> _.extend $.ui.sketch.prototype,

  _initFileModule: ->

    # Store for locally saved native cad files.
    @localFiles = Lawnchair {}, (store) ->
      console.log "local storage initialized"
    @_initFileMenu()
    @_initFileShortcutKeys()


  _initFileMenu: ->
    # File bar buttons
    #--------------------------------

    $(".file-new").click => @reset()


    # Selecting a file to load (in the load modal)
    $(document).on "click", ".load-file-list .nav.nav-list li:not('.nav-header')", (e) ->
      $item = $(this)
      $list = $item.closest(".nav.nav-list")
      $list.find("li").removeClass("active")
      $item.addClass("active")

    # Selecting a file to save over (in the save as modal)
    $(document).on "click", ".save-as-file-list .nav.nav-list li:not('.nav-header')", (e) ->
      $item = $(this)
      $item.closest(".modal-body").find(".file-name-input").val $item.data("file-name")


    # The load and save modal templates
    @_loadTemplate = Handlebars.compile $("#load-modal-template").html()
    @_saveAsTemplate = Handlebars.compile $("#save-as-modal-template").html()

    # Finishing the open transaction or displaying an error
    $(document).on "click", ".open-btn", (e) =>
      $modal = $(e.target).closest(".modal")
      filename = $modal.find("li.active").data("file-name")
      console.log "opening '#{filename}'"
      @load(filename)
      $modal.modal("hide")

    # Finishing the save as transaction or displaying an error
    $(document).on "click", ".save-as-btn", (e) =>
      $modal = $(e.target).closest(".modal")
      filename = $modal.find(".file-name-input").val()
      console.log "saving as '#{filename}'"
      @save(filename)
      $modal.modal("hide")

    # File Menu Buttons
    $(".file-open").click => @load()
    $(".file-save-as").click => @openSaveAsModal()
    $(".file-save").click => @save()


  _initFileShortcutKeys: ->
    # Keyboard bindings
    $("body").bind "keydown", "ctrl+s", =>
      @save()
      return false
    $("body").bind "keydown", "ctrl+shift+s", =>
      @openSaveAsModal()
      return false
    $("body").bind "keydown", "ctrl+l", =>
      console.log "moocow!"
      @load()
      return false


  name: (name) ->
    if name?
      @_name = name
      return null
    if @_name?
      return @_name
    else
      throw "no sketch name"


  # Saves the sketch to either a new file or it's existing file depending on the argument
  # save() # -> saves the sketch to it's previous location or prompts with a save as dialog for a new file
  # save("my sketch") # -> saves the sketch under the file name "my sketch"
  save: (name = @_name) ->
    if name?
      @_saveToLocalDB(name)
    else
      @openSaveAsModal()


  openSaveAsModal: -> @fileNames (files) =>
    data = {files: files}
    $('#save-as-modal').html( @_saveAsTemplate(data) ).addClass("modal").modal()


  load: (name) ->
    return @_loadFromLocalDB(name) if name?
    # if no file name is specified open the load modal
    @fileNames (files) =>
      data = {files: files}
      # data = {files: ["my cad file 1","another cad file b","a way better file c"]}
      console.log data
      $('#load-modal').html( @_loadTemplate(data) ).addClass("modal").modal()


  # Saves the sketch to a browser local store. Later versions may also synchronize with remote cad repositories
  _saveToLocalDB: ( name = @name() ) ->
    console.log "saving locally.."
    @localFiles.save { name: name, data: @serialize("json") }
    console.log "saved."


  # Asynchronously loads the sketch from a browser local store.
  # Later versions may also allow loading from remote cad repositories
  _loadFromLocalDB: (name = @name()) -> Lawnchair (store) => store.all (files) =>
    f = _.find files, (f) => (f.name == name)
    console.log name
    console.log f
    @deserialize(f.data, "json")


  # Maybe move this out of the scope of Sketch and into jQuery.fn?
  # List all the CAD files in the browser's local store
  fileNames: (fn) -> Lawnchair (store) => store.all (files) =>
    console.log files
    fn _.map files, (f) -> f.name

  # Exports the sketch to the given file format and prompts the user to download it.
  # This technically works for the default file format but it's very hackish.
  download: (format=".cadprototype.yaml") ->
    # TODO: Downloadify for exported CNC-ready files and interchange formats
    $("body").downloadify
      filename: => "cadprototypeExport#{format}"
      data: => @serialize("yaml")
      onComplete: -> console.log('Your File Has Been Saved!')
      onCancel: console.log('You have cancelled the saving of this file.')
      onError: console.log('You must put something in the File Contents or there will be nothing to save!')
      swf: '/lib/media/downloadify/downloadify.swf',
      downloadImage: '/lib/media/downloadify/download.png',
      width: 100,
      height: 30,
      transparent: true,
      append: false

