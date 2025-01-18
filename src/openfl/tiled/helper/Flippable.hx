package openfl.tiled.helper;

/**
 * Flippable interface
 */
interface Flippable {
  /**
   * Helper for flipped horizontally checks
   * @return True if flipped horizontally, else false
   */
  public function isFlippedHorizontally():Bool;

  /**
   * Helper for flipped vertically checks
   * @return True if flipped vertically, else false
   */
  public function isFlippedVertically():Bool;

  /**
   * Helper for flipped diagonally checks
   * @return True if flipped diagonally, else false
   */
  public function isFlippedDiagonally():Bool;

  /**
   * Helper for flipped hexagonal 120 checks
   * @return True if rotated hexagonal by 120, else false
   */
  public function isRotatedHexagonal120():Bool;
}
