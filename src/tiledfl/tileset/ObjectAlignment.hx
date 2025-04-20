package tiledfl.tileset;

/**
 * Object alignment enum
 */
enum abstract ObjectAlignment(String) {
  /**
   * Object alignment unspecified
   */
  var TilesetObjectAlignmentUnspecified = "unspecified";

  /**
   * Object alignment top left
   */
  var TilesetObjectAlignmentTopLeft = "topleft";

  /**
   * Object alignment top
   */
  var TilesetObjectAlignmentTop = "top";

  /**
   * Object alignment top right
   */
  var TilesetObjectAlignmentTopRight = "topright";

  /**
   * Object alignment left
   */
  var TilesetObjectAlignmentLeft = "left";

  /**
   * Object alignment left center
   */
  var TilesetObjectAlignmentCenter = "leftcenter";

  /**
   * Object alignment right
   */
  var TilesetObjectAlignmentRight = "right";

  /**
   * Object alignment bottom left
   */
  var TilesetObjectAlignmentBottomLeft = "bottomleft";

  /**
   * Object alignment bottom
   */
  var TilesetObjectAlignmentBottom = "bottom";

  /**
   * Object alignment bottom right
   */
  var TilesetObjectAlignmentBottomRight = "bottomright";
}
