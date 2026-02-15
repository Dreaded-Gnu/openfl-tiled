package tiledfl.object;

/**
 * Tiled ellipse object
 */
class Ellipse implements Disposable
{
  private var mObject:tiledfl.Object;
  private var mDisposed:Bool;

  /**
   * Constructor
   * @param node node data to parse
   * @param object object instance this object belongs to
   */
  public function new(node:Xml, object:tiledfl.Object)
  {
    this.mDisposed = false;
    this.mObject = object;
  }

  /**
   * Dispose method
   */
  public function dispose():Void
  {
    this.mDisposed = true;
    this.mObject = null;
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
