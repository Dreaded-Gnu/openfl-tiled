package tiledfl.tileset;

/**
 * Transformations representation
 */
class Transformations {
  /**
   * Horizontally flipped
   */
  public var hflip(default, null):Int;

  /**
   * Vertically flipped
   */
  public var vflip(default, null):Int;

  /**
   * Rotated
   */
  public var rotate(default, null):Int;

  /**
   * Prefer untransformed
   */
  public var preferuntransformed(default, null):Int;

  /**
   * Constructor
   */
  public function new() {}
}
