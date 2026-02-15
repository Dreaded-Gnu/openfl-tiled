package tiledfl.tileset;

/**
 * Tile offset representation
 */
class TileOffset implements Disposable
{
  /**
   * Offset on x axis
   */
  public var x(default, null):Float;

  /**
   * Offset on y axis
   */
  public var y(default, null):Float;

  private var mDisposed:Bool;

  /**
   * Constructor
   * @param node xml representation to parse
   */
  public function new(node:Xml)
  {
    this.mDisposed = false;
    this.x = node != null ? Std.parseInt(node.get("x")) : 0;
    this.y = node != null ? Std.parseInt(node.get("y")) : 0;
  }

  /**
   * Dispose method
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
