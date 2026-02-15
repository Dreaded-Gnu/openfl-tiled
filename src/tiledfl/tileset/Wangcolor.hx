package tiledfl.tileset;

/**
 * Wang color representation
 */
class Wangcolor implements tiledfl.Disposable
{
  /**
   * Name
   */
  public var name(default, null):String;

  /**
   * class
   */
  public var klass(default, null):String;

  /**
   * Color
   */
  public var color(default, null):String;

  /**
   * Tile
   */
  public var tile(default, null):Int;

  /**
   * Prbability
   */
  public var probability(default, null):Int;

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
