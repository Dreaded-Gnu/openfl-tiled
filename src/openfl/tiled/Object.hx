package openfl.tiled;

class Object {
  public var id(default, null):Int;
  public var name(default, null):String;
  public var type(default, null):String;
  public var x(default, null):Int;
  public var y(default, null):Int;
  public var width(default, null):Int;
  public var height(default, null):Int;
  public var rotation(default, null):Float;
  public var gid(get, null):Int;
  public var visible(default, null):Int;
  public var template(default, null):String;
  public var properties(default, null):openfl.tiled.Properties;
  public var ellipse(default, null):openfl.tiled.object.Ellipse;
  public var point(default, null):openfl.tiled.object.Point;
  public var polygon(default, null):openfl.tiled.object.Polygon;
  public var polyline(default, null):openfl.tiled.object.Polyline;
  public var text(default, null):openfl.tiled.object.Text;

  // flip information
  public var flipped_horizontally(get, null):Bool;
  public var flipped_vertically(get, null):Bool;
  public var flipped_diagonally(get, null):Bool;
  public var rotated_hexagonal_120(get, null):Bool;

  private var mMap:openfl.tiled.Map;

  /**
   * Constructor
   * @param node
   * @param map
   */
  public function new(node:Xml, map:openfl.tiled.Map) {
    mMap = map;
    // parse properties
    this.id = node.exists("id") ? Std.parseInt(node.get("id")) : 0;
    this.name = node.exists("name") ? node.get("name") : "";
    this.type = node.exists("type") ? node.get("type") : "";
    this.x = node.exists("x") ? Std.parseInt(node.get("x")) : 0;
    this.y = node.exists("y") ? Std.parseInt(node.get("y")) : 0;
    this.width = node.exists("width") ? Std.parseInt(node.get("width")) : 0;
    this.height = node.exists("height") ? Std.parseInt(node.get("height")) : 0;
    this.rotation = node.exists("rotation") ? Std.parseInt(node.get("rotation")) : 0;
    this.gid = node.exists("gid") ? Std.parseInt(node.get("gid")) : 0;
    this.visible = node.exists("visible") ? Std.parseInt(node.get("visible")) : 1;
    this.template = node.get("template");
    // loop through childs
    for (child in node) {
      if (child.nodeType != Xml.Element) {
        // skip non elements
        continue;
      }
      switch (child.nodeName) {
        case "properties":
          this.properties = new openfl.tiled.Properties(child);
        case "ellipse":
          this.ellipse = new openfl.tiled.object.Ellipse(child, this);
        case "point":
          this.point = new openfl.tiled.object.Point(child, this);
        case "polygon":
          this.polygon = new openfl.tiled.object.Polygon(child, this);
        case "polyline":
          this.polyline = new openfl.tiled.object.Polyline(child, this);
        case "text":
          this.text = new openfl.tiled.object.Text(child, this);
      }
    }
  }

  /**
   * Getter for gid property
   * @return Int
   */
  private function get_gid():Int {
    return Helper.extractGid(this.gid);
  }

  /**
   * Getter for flipped horizontally
   * @return Bool
   */
  private function get_flipped_horizontally():Bool {
    return Helper.isGidFlippedHorizontally(this.gid);
  }

  /**
   * Getter for flipped vertically
   * @return Bool
   */
  private function get_flipped_vertically():Bool {
    return Helper.isGidFlippedVertically(this.gid);
  }

  /**
   * Getter for flipped diagonally
   * @return Bool
   */
  private function get_flipped_diagonally():Bool {
    return Helper.isGidFlippedDiagonally(this.gid);
  }

  /**
   * Getter for flipped hexagonal 120
   * @return Bool
   */
  private function get_rotated_hexagonal_120():Bool {
    return Helper.isGidRotatedHexagonal120(this.gid);
  }

  /**
   * Checks for collision with sprite
   * @param sprite
   * @return Bool
   */
  public function collides(sprite:openfl.display.Sprite):Bool {
    /// FIXME: ADD LOGIC
    return false;
  }
}
