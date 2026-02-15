package tiledfl.tileset;

/**
 * Transformations representation
 */
class Transformations implements tiledfl.Disposable
{
  /**
   * Horizontally flipped
   */
  public var hflip(default, null):Int;

  /**
   * Vertically flipped
   */
  public var vflip(default, null):Int;

  /**
   * Rotated
   */
  public var rotate(default, null):Int;

  /**
   * Prefer untransformed
   */
  public var preferuntransformed(default, null):Int;

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
