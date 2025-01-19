package openfl.tiled.object;

/**
 * Tiled point object
 */
class Point {
  private var object:openfl.tiled.Object;

  /**
   * Constructor
   * @param node node data to parse
   * @param object object instance this object belongs to
   */
  public function new(node:Xml, object:openfl.tiled.Object) {
    this.object = object;
  }
}
