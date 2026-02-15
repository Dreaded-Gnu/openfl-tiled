package tiledfl.tileset;

/**
 * Tiled terrain object
 */
class Terrain implements Disposable
{
  /**
   * Terrain name
   */
  public var name(default, null):String;

  /**
   * Tile id
   */
  public var tile(default, null):Int;

  private var mDisposed:Bool;

  /**
   * Constructor
   */
  public function new()
  {
    this.mDisposed = false;
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
