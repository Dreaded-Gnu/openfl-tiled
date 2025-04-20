package tiledfl.object;

/**
 * Tiled point object
 */
class Point {
  private var object:tiledfl.Object;

  /**
   * Constructor
   * @param node node data to parse
   * @param object object instance this object belongs to
   */
  public function new(node:Xml, object:tiledfl.Object) {
    this.object = object;
  }
}
