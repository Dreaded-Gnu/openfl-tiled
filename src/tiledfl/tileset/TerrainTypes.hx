package tiledfl.tileset;

/**
 * Terrain types representation
 */
class TerrainTypes extends RootObject
{
  /**
   * Array of terrain elements
   */
  public var terrain(default, null):Array<Terrain>;

  /**
   * Constructor
   */
  public function new()
  {
    super();
    this.terrain = new Array<Terrain>();
  }

  /**
   * Dispose method
   */
  override public function dispose():Void
  {
    super.dispose();
    this.terrain = cast this.destroyArray(this.terrain);
  }
}
