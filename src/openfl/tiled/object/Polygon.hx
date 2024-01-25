package openfl.tiled.object;

class Polygon {
  public var points(default, null):Array<openfl.geom.Point>;

  private var object:openfl.tiled.Object;

  /**
   * Constructor
   * @param node
   * @param object
   */
  public function new(node:Xml, object:openfl.tiled.Object) {
    this.object = object;
    this.points = new Array<openfl.geom.Point>();
    // get points string
    var p:String = node.get("points");
    if (p == null) {
      return;
    }
    // explode by space
    var splittedPoints:Array<String> = p.split(" ");
    for (splittedPoint in splittedPoints) {
      var point:Array<String> = splittedPoint.split(",");
      this.points.push(new openfl.geom.Point(
        Std.parseFloat(point[0]),
        Std.parseFloat(point[1])
      ));
    }
  }
}
