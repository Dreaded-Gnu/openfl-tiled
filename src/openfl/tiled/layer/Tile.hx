package openfl.tiled.layer;

class Tile implements openfl.tiled.helper.Flippable {
  public var gid(get, null):Int;

  private var mGid:Int;

  /**
   * Constructor
   * @param gid
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
   * Getter for flipped horizontally
   * @return Bool
   */
  public function isFlippedHorizontally():Bool {
    return Helper.isGidFlippedHorizontally(this.mGid);
  }

  /**
   * Getter for flipped vertically
   * @return Bool
   */
  public function isFlippedVertically():Bool {
    return Helper.isGidFlippedVertically(this.mGid);
  }

  /**
   * Getter for flipped diagonally
   * @return Bool
   */
  public function isFlippedDiagonally():Bool {
    return Helper.isGidFlippedDiagonally(this.mGid);
  }

  /**
   * Getter for flipped hexagonal 120
   * @return Bool
   */
  public function isRotatedHexagonal120():Bool {
    return Helper.isGidRotatedHexagonal120(this.mGid);
  }
}
