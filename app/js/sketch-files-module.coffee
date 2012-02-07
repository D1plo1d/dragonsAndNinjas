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

    # File Menu Buttons
    $(".file-open").click => @load()
    $(".file-save-as").click => @_openLocalFileModal("save")
    $(".file-save").click => @save()

    # Delete File(s) Button
    @deleteFilesTemplate ?= Handlebars.compile $("#delete-files-warning-template").html()
    $(document).on "click", ".file-modal .btn-delete", (e) =>
      console.log "clicked!"
      $modal = $(e.currentTarget).closest(".file-modal")
      fileNames = $modal.fileModal("selectedFileNames")

      # warn about the impending deletion
      $warning = $( $("<div class='modal'></div>").appendTo("body") )
      $warning.html( @deleteFilesTemplate(files: fileNames) ).modal()
      $warning.on "click", ".btn-warning", =>
        console.log "deleting?"
        @_deleteLocalFiles(fileNames)


  _initFileShortcutKeys: ->
    # Keyboard bindings
    $("body").bind "keydown", "ctrl+s", =>
      @save()
      return false
    $("body").bind "keydown", "ctrl+shift+s", =>
      @_openLocalFileModal("save")
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
    if name? then @_saveToLocalDB(name) else @_openLocalFileModal("save")
    return true


  load: (name) ->
    console.log name
    if name? then @_loadFromLocalDB(name) else @_openLocalFileModal("load")
    return true


  # opens a local file modal. Specifically this opens either a save-as modal or a load modal
  _openLocalFileModal: (op) -> @fileNames (files) =>
    t = if op == "save" then "save-as" else op # the template's css name
    $("##{t}-modal").fileModal(template: t, files: files).on "fileselected", (e) => this[op](e.fileName)


  _findLocalFile: (name = @name(), fn) -> Lawnchair (store) => store.all (files) =>
    fn( _.find files, (f) => (f.name == name) )

  _deleteLocalFiles: (fileNames) ->
    for name in fileNames
      console.log "deleteing #{name}"
      @_findLocalFile name, (file) ->
        return unless file?
        Lawnchair (store) => store.remove file.key, =>
          $(document).trigger $.Event("cadfilesdeleted", fileNames: [name])



  # Saves the sketch to a browser local store. Later versions may also synchronize with remote cad repositories
  _saveToLocalDB: ( name = @name() ) -> @_findLocalFile name, (previousFile) =>
    console.log "saving locally.."
    file = { name: name, data: @serialize("json") }
    # set the key if we are overwriting an existing file of the same name
    file.key = previousFile.key if previousFile?
    # save the file and update the sketch's name
    @localFiles.save file
    @name(name)
    console.log "saved."


  # Asynchronously loads the sketch from a browser local store.
  # Later versions may also allow loading from remote cad repositories
  _loadFromLocalDB: (name = @name()) -> @_findLocalFile name, (f) =>
    throw "local file does not exist: #{name}" unless f?

    console.log name
    console.log f
    @deserialize(f.data, "json")
    @name(name)


  # Maybe move this out of the scope of Sketch and into jQuery.fn?
  # List all the CAD files in the browser's local store
  fileNames: (fn) -> Lawnchair (store) => store.all (files) =>
    console.log files
    fn (_.map files, (f) -> f.name).sort (a,b) -> a.toLowerCase().compare(b.toLowerCase())


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

