package tiledfl.map;

/**
 * Tiled map render order enum
 */
enum abstract RenderOrder(String) {
  /**
   * Render order right down
   */
  var MapRenderOrderRightDown = "right-down";

  /**
   * Render order right up
   */
  var MapRenderOrderRightUp = "right-up";

  /**
   * Render order left down
   */
  var MapRenderOrderLeftDown = "left-down";

  /**
   * Render order left up
   */
  var MapRenderOrderLeftUp = "left-up";
}
