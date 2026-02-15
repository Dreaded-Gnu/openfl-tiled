package tiledfl.tileset;

/**
 * Frame representation
 */
class Frame extends tiledfl.RootObject
{
  /**
   * Tile id of the frame
   */
  public var tileid(default, null):Int;

  /**
   * Duration of the frame
   */
  public var duration(default, null):Int;

  /**
   * Constructor
   * @param node xml representation to parse
   */
  public function new(node:Xml)
  {
    super();
    this.tileid = Std.parseInt(node.get("tileid"));
    this.duration = Std.parseInt(node.get("duration"));
  }
}
