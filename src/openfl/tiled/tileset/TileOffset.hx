package openfl.tiled.tileset;

class TileOffset {
  public var x(default, null):Int;
  public var y(default, null):Int;

  /**
   * Constructor
   * @param node
   */
  public function new(node:Xml) {
    if (null != node) {
      this.x = Std.parseInt(node.get("x"));
      this.y = Std.parseInt(node.get("y"));
    } else {
      this.x = 0;
      this.y = 0;
    }
  }
}
