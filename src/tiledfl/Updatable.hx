package tiledfl;

/**
 * Updatable interface used for updatable/displayable objects
 */
interface Updatable extends Disposable
{
  /**
   * Update method
   * @param offsetX x offset for update
   * @param offsetY y offset for update
   * @param index index
   * @return amount of added items
   */
  public function update(offsetX:Float, offsetY:Float, index:Int):Int;

  /**
   * Helper to check for collision of "rectangle" with element
   * @param x x coordinate
   * @param y y coordinate
   * @param width width
   * @param height height
   * @return true if something collides, else false
   */
  public function collides(x:Float, y:Float, width:Float, height:Float):Bool;

  /**
   * Helper to evaluate width
   * @return evaluated width
   */
  public function evaluateWidth():Float;

  /**
   * Helper to evaluate height
   * @return evaluated height
   */
  public function evaluateHeight():Float;
}
