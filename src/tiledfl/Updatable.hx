package tiledfl;

@:dox(hide) interface Updatable {
  /**
   * Update method
   * @param offsetX
   * @param offsetY
   * @param index
   */
  public function update(offsetX:Float, offsetY:Float, index:Int):Int;

  /**
   * Helper to check for collision of "rectangle" with element
   * @param x
   * @param y
   * @param width
   * @param height
   * @return Bool
   */
  public function collides(x:Float, y:Float, width:Float, height:Float):Bool;

  /**
   * Helper to evaluate width
   * @return Int
   */
  public function evaluateWidth():Float;

  /**
   * Helper to evaluate height
   * @return Int
   */
  public function evaluateHeight():Float;
}
