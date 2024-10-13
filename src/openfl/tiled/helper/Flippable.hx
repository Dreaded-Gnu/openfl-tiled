package openfl.tiled.helper;

interface Flippable {
  /**
   * Getter for flipped horizontally
   * @return Bool
   */
  public function isFlippedHorizontally():Bool;

  /**
   * Getter for flipped vertically
   * @return Bool
   */
  public function isFlippedVertically():Bool;

  /**
   * Getter for flipped diagonally
   * @return Bool
   */
  public function isFlippedDiagonally():Bool;

  /**
   * Getter for flipped hexagonal 120
   * @return Bool
   */
  public function isRotatedHexagonal120():Bool;
}
