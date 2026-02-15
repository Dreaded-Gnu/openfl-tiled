package tiledfl.tileset;

/**
 * Wangset representation
 */
class Wangset implements Disposable
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

  private var mDisposed:Bool;

  /**
   * Constructor
   */
  public function new()
  {
    this.mDisposed = false;
    this.wangcolor = new Array<tiledfl.tileset.Wangcolor>();
    this.wangtile = new Array<tiledfl.tileset.Wangtile>();
  }

  /**
   * Dispose method
   */
  public function dispose():Void
  {
    this.mDisposed = true;
    this.properties?.dispose();
    for (c in this.wangcolor)
    {
      c.dispose();
    }
    this.wangcolor = null;
    for (t in this.wangtile)
    {
      t.dispose();
    }
    this.wangtile = null;
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
