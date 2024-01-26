package openfl.tiled.layer;

class Tile {
  public var gid(get, null):Int;

  // flip information
  public var flipped_horizontally(get, null):Bool;
  public var flipped_vertically(get, null):Bool;
  public var flipped_diagonally(get, null):Bool;
  public var rotated_hexagonal_120(get, null):Bool;

  /**
   * Constructor
   * @param gid
   */
  public function new(gid:Int) {
    this.gid = gid;
  }

  /**
   * Getter for gid property
   * @return Int
   */
  private function get_gid():Int {
    return Helper.extractGid(this.gid);
  }

  /**
   * Getter for flipped horizontally
   * @return Bool
   */
  private function get_flipped_horizontally():Bool {
    return Helper.isGidFlippedHorizontally(this.gid);
  }

  /**
   * Getter for flipped vertically
   * @return Bool
   */
  private function get_flipped_vertically():Bool {
    return Helper.isGidFlippedVertically(this.gid);
  }

  /**
   * Getter for flipped diagonally
   * @return Bool
   */
  private function get_flipped_diagonally():Bool {
    return Helper.isGidFlippedDiagonally(this.gid);
  }

  /**
   * Getter for flipped hexagonal 120
   * @return Bool
   */
  private function get_rotated_hexagonal_120():Bool {
    return Helper.isGidRotatedHexagonal120(this.gid);
  }
}
