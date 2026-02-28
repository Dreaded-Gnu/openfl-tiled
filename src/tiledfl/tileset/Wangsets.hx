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
    this.wangset = cast this.destroyArray(this.wangset);
  }
}
