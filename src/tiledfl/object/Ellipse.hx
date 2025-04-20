package tiledfl.object;

/**
 * Tiled ellipse object
 */
class Ellipse {
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
