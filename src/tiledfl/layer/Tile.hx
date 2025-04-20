package tiledfl.layer;

/**
 * Tile representation
 */
class Tile implements tiledfl.helper.Flippable {
  /**
   * Gid property
   */
  public var gid(get, null):Int;

  private var mGid:Int;

  /**
   * Constructor
   * @param gid gid the tile is representing
   */
  public function new(gid:Int) {
    this.mGid = gid;
  }

  /**
   * Getter for gid property
   * @return Int
   */
  private function get_gid():Int {
    return Helper.extractGid(this.mGid);
  }

  /**
   * Helper for flipped horizontally checks
   * @return True if flipped horizontally, else false
   */
  public function isFlippedHorizontally():Bool {
    return Helper.isGidFlippedHorizontally(this.mGid);
  }

  /**
   * Helper for flipped vertically checks
   * @return True if flipped vertically, else false
   */
  public function isFlippedVertically():Bool {
    return Helper.isGidFlippedVertically(this.mGid);
  }

  /**
   * Helper for flipped diagonally checks
   * @return True if flipped diagonally, else false
   */
  public function isFlippedDiagonally():Bool {
    return Helper.isGidFlippedDiagonally(this.mGid);
  }

  /**
   * Helper for flipped hexagonal 120 checks
   * @return True if rotated hexagonal by 120, else false
   */
  public function isRotatedHexagonal120():Bool {
    return Helper.isGidRotatedHexagonal120(this.mGid);
  }
}
