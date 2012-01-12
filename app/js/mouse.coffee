# cheap global mouse position hack
window.mouse = x: -100000, y: -100000
$ -> $(document).mousemove (e) -> window.mouse = x: e.pageX, y: e.pageY

