package openfl.tiled.object;

import openfl.geom.Point;

/**
 * Tiled polygon object
 */
class Polygon {
  /**
   * Array of points of the polygon
   */
  public var points(default, null):Array<Point>;

  private var object:openfl.tiled.Object;

  /**
   * Constructor
   * @param node node data to parse
   * @param object object instance this object belongs to
   */
  public function new(node:Xml, object:openfl.tiled.Object) {
    this.object = object;
    this.points = new Array<Point>();
    // get points string
    var p:String = node.get("points");
    if (p == null) {
      return;
    }
    // explode by space
    var splittedPoints:Array<String> = p.split(" ");
    for (splittedPoint in splittedPoints) {
      var point:Array<String> = splittedPoint.split(",");
      this.points.push(new Point(Std.parseFloat(point[0]), Std.parseFloat(point[1])));
    }
  }
}
