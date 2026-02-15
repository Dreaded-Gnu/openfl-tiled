package tiledfl.tileset;

/**
 * Wangsets representation
 */
class Wangsets extends tiledfl.RootObject
{
  /**
   * Array of wangsets
   */
  public var wangset(default, null):Array<tiledfl.tileset.Wangset>;

  /**
   * Constructor
   */
  public function new()
  {
    super();
    this.wangset = new Array<tiledfl.tileset.Wangset>();
  }

  /**
   * Dispose method
   */
  override public function dispose():Void
  {
    super.dispose();
    for (w in this.wangset)
    {
      w.dispose();
    }
    this.wangset = null;
  }
}
