# This deals with the task of importing files, exporting files, saving and loading
# It is not included in sketch because it's not really core to sketching.
$ -> _.extend $.ui.sketch.prototype,

  _initFileModule: ->

    # Store for locally saved native cad files.
    Persist.remove('cookie')
    @localStore = new Persist.Store('CAD Prototype A')

    # Keyboard bindings
    $("body").bind "keydown", "ctrl+s", =>
      @save()
      return false
    $("body").bind "keydown", "ctrl+l", =>
      console.log "moocow!"
      @load()
      return false


  getFileName: () ->
    return "default project/default"


  # Saves the sketch to a browser local store. Later versions may also synchronize with remote cad repositories
  save: -> @localStore.set(@getFileName(), @serialize("json"))


  # Asynchronously loads the sketch from a browser local store.
  # Later versions may also allow loading from remote cad repositories
  load: ->
    @localStore.get @getFileName(), (ok, str) =>
      if ok == true
        console.log str
        @deserialize(str, "json")
      else
        alert("There was an error loading your file. Please try again or contact support.")


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

