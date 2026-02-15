package tiledfl.tileset;

/**
 * Tiled terrain object
 */
class Terrain extends tiledfl.RootObject
{
  /**
   * Terrain name
   */
  public var name(default, null):String;

  /**
   * Tile id
   */
  public var tile(default, null):Int;

  /**
   * Constructor
   */
  public function new()
  {
    super();
  }
}
