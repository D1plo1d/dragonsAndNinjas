This is a prototype 2d CAD program. It runs on a server and is accessible in the web browser.

Installation
============
1. Install RVM, Ruby 1.9.1 or later and gem
2. Run "gem install bunlder thin"
3. Download and unzip this project (or git pull it)
4. In the folder you saved this project to run "bundle install"

Running
=======
In the folder you saved this project to run "thin start"


Features
========
* Create shapes from a js console or via the gui
  * circles (defined by a center point + radius)
  * ovals (defined by a center point and a x and y radii)
  * lines segments (defined by a start and end point)
  * arc segments (defined by a center point, a start point and an end point)

* Create shapes quickly with keyboard modifier shortcuts
  * polygons via the create line segment command + the shift key (defined by a series of line segments)

* Click and drag paper movement (creates a google maps-like scrolling effect)

* Click and drag point movement (allows points to be repositioned to modify existing designs)
  * snap to points (points snaps to nearby points when dragging and merge when dropped)
  * coradial constraints* (*that work sometimes but are not exactly reliable)
