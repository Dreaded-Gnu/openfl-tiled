package tiledfl.tileset;

/**
 * Tile offset representation
 */
class TileOffset {
  /**
   * Offset on x axis
   */
  public var x(default, null):Int;

  /**
   * Offset on y axis
   */
  public var y(default, null):Int;

  /**
   * Constructor
   * @param node xml representation to parse
   */
  public function new(node:Xml) {
    this.x = node != null ? Std.parseInt(node.get("x")) : 0;
    this.y = node != null ? Std.parseInt(node.get("y")) : 0;
  }
}
