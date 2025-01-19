package openfl.tiled.tileset;

/**
 * Fill mode enum
 */
enum abstract FillMode(String) {
  /**
   * Fill mode stretch
   */
  var TilesetFillModeStretch = "stretch";

  /**
   * Fill mode preserve aspect fit
   */
  var TilesetFillModePreserveAspectFit = "preserve-aspect-fit";
}
