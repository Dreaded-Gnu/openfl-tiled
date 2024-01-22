package openfl.tiled.tileset;

import openfl.errors.Error;

class Grid {
  public var orientation(default, null):openfl.tiled.map.Orientation;
  public var width(default, null):Int;
  public var height(default, null):Int;

  public function new(node:Xml) {
    // parse orientation
    var o:String = node.get("orientation");
    switch (o) {
      case "orthogonal":
        this.orientation = MapOrientationOrthogonal;
      case "isometric":
        this.orientation = MapOrientationIsometric;
      default:
        throw new Error("Unsupported orientation for grid");
    }
    // parse width and height
    this.width = Std.parseInt(node.get("width"));
    this.height = Std.parseInt(node.get("height"));
  }
}
