package tiledfl.tileset;

/**
 * Wang tile representation
 */
class Wangtile {
  /**
   * Tile id
   */
  public var tileid(default, null):Int;

  /**
   * Wang id
   */
  public var wangid(default, null):String;

  /**
   * Horizontally flipped
   */
  public var hflip(default, null):Int;

  /**
   * Vertically flipped
   */
  public var vflip(default, null):Int;

  /**
   * Diagonally flipped
   */
  public var dflip(default, null):Int;

  /**
   * Constructor
   */
  public function new() {}
}
