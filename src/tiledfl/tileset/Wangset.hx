package tiledfl.tileset;

/**
 * Wangset representation
 */
class Wangset {
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
  public var properties(default, null):tiledfl.Properties;

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
  public function new() {}
}
