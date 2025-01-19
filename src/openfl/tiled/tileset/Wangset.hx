package openfl.tiled.tileset;

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
  public var properties(default, null):openfl.tiled.Properties;

  /**
   * Wang color
   */
  public var wangcolor(default, null):Array<openfl.tiled.tileset.Wangcolor>;

  /**
   * Wang tile
   */
  public var wangtile(default, null):Array<openfl.tiled.tileset.Wangtile>;

  /**
   * Constructor
   */
  public function new() {}
}
