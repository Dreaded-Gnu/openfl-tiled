package tiledfl.tileset;

import openfl.errors.Error;
import tiledfl.map.Orientation;

/**
 * Grid representation
 */
class Grid extends RootObject
{
  /**
   * Orientation of the grid
   */
  public var orientation(default, null):Orientation;

  /**
   * Grid width
   */
  public var width(default, null):Float;

  /**
   * Grid height
   */
  public var height(default, null):Float;

  /**
   * Constructor
   * @param node xml representation to parse
   */
  public function new(node:Xml)
  {
    super();
    var o:String = node.get("orientation");
    switch (o)
    {
      case "orthogonal":
        this.orientation = Orientation.MapOrientationOrthogonal;
      case "isometric":
        this.orientation = Orientation.MapOrientationIsometric;
      default:
        throw new Error("Unsupported orientation for grid");
    }
    this.width = Std.parseInt(node.get("width"));
    this.height = Std.parseInt(node.get("height"));
  }
}
