package tiledfl;

/**
 * Disposable interface
 */
interface Disposable
{
  /**
   * Dispose
   */
  public function dispose():Void;

  /**
   * Is disposed method
   * @return True if disposed, else false
   */
  public function isDisposed():Bool;
}
