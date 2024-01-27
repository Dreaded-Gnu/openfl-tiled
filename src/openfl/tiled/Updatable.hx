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
}
