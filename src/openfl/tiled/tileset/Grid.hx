package openfl.tiled.tileset;

import openfl.errors.Error;

class Grid {
  public var orientation(default, null):openfl.tiled.map.Orientation;
  public var width(default, null):Int;
  public var height(default, null):Int;

  /**
   * Constructor
   * @param node
   */
  public function new(node:Xml) {
    var o:String = node.get("orientation");
    switch (o) {
      case "orthogonal":
        this.orientation = openfl.tiled.map.Orientation.MapOrientationOrthogonal;
      case "isometric":
        this.orientation = openfl.tiled.map.Orientation.MapOrientationIsometric;
      default:
        throw new Error("Unsupported orientation for grid");
    }
    this.width = Std.parseInt(node.get("width"));
    this.height = Std.parseInt(node.get("height"));
  }
}
