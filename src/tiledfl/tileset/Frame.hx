package tiledfl.tileset;

/**
 * Frame representation
 */
class Frame implements Disposable
{
  /**
   * Tile id of the frame
   */
  public var tileid(default, null):Int;

  /**
   * Duration of the frame
   */
  public var duration(default, null):Int;

  private var mDisposed:Bool;

  /**
   * Constructor
   * @param node xml representation to parse
   */
  public function new(node:Xml)
  {
    this.mDisposed = false;
    this.tileid = Std.parseInt(node.get("tileid"));
    this.duration = Std.parseInt(node.get("duration"));
  }

  /**
   * Dispose
   */
  public function dispose():Void
  {
    this.mDisposed = true;
  }

  /**
   * Is disposed
   * @return true if disposed, else false
   */
  public function isDisposed():Bool
  {
    return this.mDisposed;
  }
}
