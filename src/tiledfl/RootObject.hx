package tiledfl;

import openfl.events.EventDispatcher;

/**
 * Root object
 */
class RootObject extends EventDispatcher implements Disposable
{
  private var mDisposed:Bool;

  /**
   * Constructor
   */
  public function new()
  {
    super();
    this.mDisposed = false;
  }

  /**
   * Dispose implementation
   */
  public function dispose():Void
  {
    this.mDisposed = true;
  }

  /**
   * Is disposed method
   * @return true when object is disposed, else false
   */
  public function isDisposed():Bool
  {
    return this.mDisposed;
  }
}
