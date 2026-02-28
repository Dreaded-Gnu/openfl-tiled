package tiledfl.tileset;

/**
 * Wangset representation
 */
class Wangset extends tiledfl.RootObject
{
  /**
   * Name
   */
  public var name(default, null):String;

  /**
   * Class
   */
  public var klass(default, null):String;

  /**
   * Tile
   */
  public var tile(default, null):Int;

  /**
   * Wangset properties
   */
  public var properties(default, null):Null<tiledfl.Properties>;

  /**
   * Wang color
   */
  public var wangcolor(default, null):Array<tiledfl.tileset.Wangcolor>;

  /**
   * Wang tile
   */
  public var wangtile(default, null):Array<tiledfl.tileset.Wangtile>;

  /**
   * Constructor
   */
  public function new()
  {
    super();
    this.wangcolor = new Array<tiledfl.tileset.Wangcolor>();
    this.wangtile = new Array<tiledfl.tileset.Wangtile>();
  }

  /**
   * Dispose method
   */
  override public function dispose():Void
  {
    super.dispose();
    this.properties?.dispose();
    this.wangcolor = cast this.destroyArray(this.wangcolor);
    this.wangtile = cast this.destroyArray(this.wangtile);
  }
}
