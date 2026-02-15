package tiledfl.tileset;

/**
 * Terrain types representation
 */
class TerrainTypes implements tiledfl.Disposable
{
  /**
   * Array of terrain elements
   */
  public var terrain(default, null):Array<tiledfl.tileset.Terrain>;

  private var mDisposed:Bool;

  /**
   * Constructor
   */
  public function new()
  {
    this.mDisposed = false;
    this.terrain = new Array<tiledfl.tileset.Terrain>();
  }

  /**
   * Dispose method
   */
  public function dispose():Void
  {
    this.mDisposed = true;
    for (t in this.terrain)
    {
      t.dispose();
    }
    this.terrain = null;
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
