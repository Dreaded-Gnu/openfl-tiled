package tiledfl.tileset;

/**
 * Terrain types representation
 */
class TerrainTypes extends tiledfl.RootObject
{
  /**
   * Array of terrain elements
   */
  public var terrain(default, null):Array<tiledfl.tileset.Terrain>;

  /**
   * Constructor
   */
  public function new()
  {
    super();
    this.terrain = new Array<tiledfl.tileset.Terrain>();
  }

  /**
   * Dispose method
   */
  override public function dispose():Void
  {
    super.dispose();
    for (t in this.terrain)
    {
      t.dispose();
    }
    this.terrain = null;
  }
}
