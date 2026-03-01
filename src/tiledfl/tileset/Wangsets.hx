package tiledfl.tileset;

/**
 * Wangsets representation
 */
class Wangsets extends RootObject
{
  /**
   * Array of wangsets
   */
  public var wangset(default, null):Array<Wangset>;

  /**
   * Constructor
   */
  public function new()
  {
    super();
    this.wangset = new Array<Wangset>();
  }

  /**
   * Dispose method
   */
  override public function dispose():Void
  {
    super.dispose();
    this.wangset = cast this.destroyArray(this.wangset);
  }
}
