package tiledfl.tileset;

import openfl.errors.Error;

/**
 * Grid representation
 */
class Grid implements Disposable
{
  /**
   * Orientation of the grid
   */
  public var orientation(default, null):tiledfl.map.Orientation;

  /**
   * Grid width
   */
  public var width(default, null):Float;

  /**
   * Grid height
   */
  public var height(default, null):Float;

  private var mDisposed:Bool;

  /**
   * Constructor
   * @param node xml representation to parse
   */
  public function new(node:Xml)
  {
    this.mDisposed = false;
    var o:String = node.get("orientation");
    switch (o)
    {
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

  /**
   * Dispose method
   */
  public function dispose():Void
  {
    this.mDisposed = true;
  }

  /**
   * Is disposed
   * @return true if disposed, else false
   */
  public function isDisposed():Bool
  {
    return this.mDisposed;
  }
}
