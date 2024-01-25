package openfl.tiled.layer;

class Tile {
  public var gid(get, null):Int;

  // flip information
  public var flipped_horizontally(get, null):Bool;
  public var flipped_vertically(get, null):Bool;
  public var flipped_diagonally(get, null):Bool;
  public var flipped_hexagonal_120(get, null):Bool;

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
    return this.gid & ~(
      Helper.GID_FLIPPED_HORIZONTALLY_FLAG
      | Helper.GID_FLIPPED_VERTICALLY_FLAG
      | Helper.GID_FLIPPED_DIAGONALLY_FLAG
      | Helper.GID_ROTATED_HEXAGONAL_120_FLAG
    );
  }

  /**
   * Getter for flipped horizontally
   * @return Bool
   */
  private function get_flipped_horizontally():Bool {
    return this.gid & Helper.GID_FLIPPED_HORIZONTALLY_FLAG ==
      Helper.GID_FLIPPED_HORIZONTALLY_FLAG;
  }

  /**
   * Getter for flipped vertically
   * @return Bool
   */
  private function get_flipped_vertically():Bool {
    return this.gid & Helper.GID_FLIPPED_VERTICALLY_FLAG ==
      Helper.GID_FLIPPED_VERTICALLY_FLAG;
  }

  /**
   * Getter for flipped diagonally
   * @return Bool
   */
  private function get_flipped_diagonally():Bool {
    return this.gid & Helper.GID_FLIPPED_DIAGONALLY_FLAG ==
      Helper.GID_FLIPPED_DIAGONALLY_FLAG;
  }

  /**
   * Getter for flipped hexagonal 120
   * @return Bool
   */
  private function get_flipped_hexagonal_120():Bool {
    return this.gid & Helper.GID_ROTATED_HEXAGONAL_120_FLAG ==
      Helper.GID_ROTATED_HEXAGONAL_120_FLAG;
  }
}
