package openfl.tiled.map;

/**
 * Tiled map orientation enum
 */
enum abstract Orientation(String) {
  /**
   * Orthogonal map
   */
  var MapOrientationOrthogonal = "orthogonal";

  /**
   * Isometric map
   */
  var MapOrientationIsometric = "isometric";

  /**
   * Isometric staggered map
   */
  var MapOrientationStaggered = "staggered";

  /**
   * Hexagonal map
   */
  var MapOrientationHexagonal = "hexagonal";
}
