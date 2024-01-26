package openfl.tiled.tileset;

class Frame {
  public var tileid(default, null):Int;
  public var duration(default, null):Int;

  /**
   * Constructor
   * @param node
   */
  public function new(node:Xml) {
    this.tileid = Std.parseInt(node.get("tileid"));
    this.duration = Std.parseInt(node.get("duration"));
  }
}
