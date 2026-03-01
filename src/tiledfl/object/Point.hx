package tiledfl.object;

/**
 * Tiled point object
 */
class Point extends RootObject
{
  private var mObject:Object;

  /**
   * Constructor
   * @param node node data to parse
   * @param object object instance this object belongs to
   */
  public function new(node:Xml, object:Object)
  {
    super();
    this.mObject = object;
  }

  /**
   * Dispose method
   */
  override public function dispose():Void
  {
    super.dispose();
    this.mObject = null;
  }
}
