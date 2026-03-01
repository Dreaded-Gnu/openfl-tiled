package tiledfl;

import haxe.ds.WeakMap;
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

  /**
   * Callback to destroy an object
   * @param a
   */
  private function destroy(a:Dynamic):Void
  {
    if (Std.isOfType(a, Disposable))
    {
      cast(a, Disposable).dispose();
    }
    else if (Std.isOfType(a, Array))
    {
      this.destroyArray(cast(a, Array<Dynamic>));
    }
  }

  /**
   * Wrapper to destroy an array
   * @param a
   */
  public function destroyArray(a:Array<Dynamic>, returnEmpty:Bool = false):Null<Array<Dynamic>>
  {
    var e:Dynamic = null;
    // loop through array
    do
    {
      // shift away element
      e = a.shift();
      // try to destroy it
      this.destroy(e);
      // shift away next element
      e = a.shift();
    } while (e != null);
    // return depending on flag
    return returnEmpty ? a : null;
  }
}
