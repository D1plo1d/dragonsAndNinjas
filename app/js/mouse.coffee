# cheap global mouse position hack
window.mouse = x:0, y:0
$ -> $(document).mousemove (e) -> window.mouse = x: e.pageX, y: e.pageY

