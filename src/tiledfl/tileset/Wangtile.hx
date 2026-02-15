package tiledfl.tileset;

/**
 * Wang tile representation
 */
class Wangtile implements Disposable
{
  /**
   * Tile id
   */
  public var tileid(default, null):Int;

  /**
   * Wang id
   */
  public var wangid(default, null):String;

  /**
   * Horizontally flipped
   */
  public var hflip(default, null):Int;

  /**
   * Vertically flipped
   */
  public var vflip(default, null):Int;

  /**
   * Diagonally flipped
   */
  public var dflip(default, null):Int;

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
