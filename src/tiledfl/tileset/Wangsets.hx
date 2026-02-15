package tiledfl.tileset;

/**
 * Wangsets representation
 */
class Wangsets implements tiledfl.Disposable
{
  /**
   * Array of wangsets
   */
  public var wangset(default, null):Array<tiledfl.tileset.Wangset>;

  private var mDisposed:Bool;

  /**
   * Constructor
   */
  public function new()
  {
    this.mDisposed = false;
    this.wangset = new Array<tiledfl.tileset.Wangset>();
  }

  /**
   * Dispose method
   */
  public function dispose():Void
  {
    this.mDisposed = true;
    for (w in this.wangset)
    {
      w.dispose();
    }
    this.wangset = null;
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
