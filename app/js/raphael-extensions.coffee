# The distance between 2 points
Raphael.distance = (points) -> # points = {x: x1, y: y1}, {x: x2, y: y2}
  distance = 0
  distance += Math.pow(points[0][a] - points[1][a], 2) for a in ['x', 'y']
  return Math.sqrt(distance)


