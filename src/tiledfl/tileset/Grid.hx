package tiledfl.tileset;

import openfl.errors.Error;

/**
 * Grid representation
 */
class Grid {
  /**
   * Orientation of the grid
   */
  public var orientation(default, null):tiledfl.map.Orientation;

  /**
   * Grid width
   */
  public var width(default, null):Int;

  /**
   * Grid height
   */
  public var height(default, null):Int;

  /**
   * Constructor
   * @param node xml representation to parse
   */
  public function new(node:Xml) {
    var o:String = node.get("orientation");
    switch (o) {
      case "orthogonal":
        this.orientation = tiledfl.map.Orientation.MapOrientationOrthogonal;
      case "isometric":
        this.orientation = tiledfl.map.Orientation.MapOrientationIsometric;
      default:
        throw new Error("Unsupported orientation for grid");
    }
    this.width = Std.parseInt(node.get("width"));
    this.height = Std.parseInt(node.get("height"));
  }
}
