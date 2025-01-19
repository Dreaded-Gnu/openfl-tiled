package openfl.tiled.objectgroup;

/**
 * Object group draw order enum
 */
enum abstract DrawOrder(String) {
  /**
   * Draw object group by index
   */
  var ObjectGroupDrawOrderIndex = "index";

  /**
   * Draw object group top down
   */
  var ObjectGroupDrawOrderTopDown = "topdown";
}
