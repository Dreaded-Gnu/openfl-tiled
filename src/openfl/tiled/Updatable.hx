package openfl.tiled;

interface Updatable {
  /**
   * Update method
   * @param tilemap
   * @param offsetX
   * @param offsetY
   */
  public function update(tilemap:openfl.display.Tilemap, offsetX:Int, offsetY:Int):Void;

  /**
   * Helper to check for collision of "rectangle" with element
   * @param x
   * @param y
   * @param width
   * @param height
   * @return Bool
   */
  public function collides(x:Int, y:Int, width:Int, height:Int):Bool;

  /**
   * Helper to evaluate width
   * @return Int
   */
  public function evaluateWidth():Int;

  /**
   * Helper to evaluate height
   * @return Int
   */
  public function evaluateHeight():Int;
}
