# Cheap little hack to get rid of errors for including logging statements in non-chrome
unless console? and console.log?
  window.console = new Object()
  window.console.log = (text) ->
    #nothing
