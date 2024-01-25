package openfl.tiled.object;

class Point {
  private var object:openfl.tiled.Object;

  /**
   * Constructor
   * @param node
   * @param object
   */
  public function new(node:Xml, object:openfl.tiled.Object) {
    this.object = object;
  }
}
