package openfl.tiled;

interface Updatable {
  /**
   * Update method
   * @param tilemap
   * @param offsetX
   * @param offsetY
   * @param previousOffsetX
   * @param previousOffsetY
   */
  public function update(tilemap:openfl.display.Tilemap, offsetX:Int, offsetY:Int, previousOffsetX:Int, previousOffsetY:Int):Void;

  /**
   * Helper to check for collision of sprite with element
   * @param sprite
   * @return Bool
   */
  public function collides(sprite:openfl.display.Sprite):Bool;
}
