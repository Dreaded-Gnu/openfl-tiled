package openfl.tiled;

class ObjectGroup implements openfl.tiled.Updatable {
  public var id(default, null):Int;
  public var name(default, null):String;
  public var klass(default, null):String;
  public var color(default, null):UInt;
  public var x(default, null):Int;
  public var y(default, null):Int;
  public var width(default, null):Int;
  public var height(default, null):Int;
  public var opacity(default, null):Float;
  public var visible(default, null):Int;
  public var tintcolor(default, null):String;
  public var offsetx(default, null):Int;
  public var offsety(default, null):Int;
  public var parallaxx(default, null):Int;
  public var parallaxy(default, null):Int;
  public var draworder(default, null):openfl.tiled.objectgroup.DrawOrder;
  public var properties(default, null):openfl.tiled.Properties;
  public var object(default, null):Array<openfl.tiled.Object>;

  private var mMap:openfl.tiled.Map;

  /**
   * Constructor
   * @param node
   * @param map
   */
  public function new(node:Xml, map:openfl.tiled.Map) {
    this.mMap = map;
    // parse properties
    this.id = node.exists("id") ? Std.parseInt(node.get("id")) : 0;
    this.name = node.exists("name") ? node.get("name") : "";
    this.klass = node.exists("class") ? node.get("class") : "";
    this.color = node.exists("color") ? Std.parseInt("0xFF" + node.get("color")) : 0x00000000;
    this.x = node.exists("x") ? Std.parseInt(node.get("x")) : 0;
    this.y = node.exists("y") ? Std.parseInt(node.get("y")) : 0;
    this.width = node.exists("width") ? Std.parseInt(node.get("width")) : 0;
    this.height = node.exists("height") ? Std.parseInt(node.get("height")) : 0;
    this.opacity = node.exists("opacity") ? Std.parseFloat(node.get("opacity")) : 1;
    this.visible = node.exists("visible") ? Std.parseInt(node.get("visible")) : 1;
    this.tintcolor = node.get("tintcolor");
    this.offsetx = node.exists("offsetx") ? Std.parseInt(node.get("offsetx")) : 0;
    this.offsety = node.exists("offsety") ? Std.parseInt(node.get("offsety")) : 0;
    this.parallaxx = node.exists("parallaxx") ? Std.parseInt(node.get("parallaxx")) : 1;
    this.parallaxy = node.exists("parallaxy") ? Std.parseInt(node.get("parallaxy")) : 1;
    var d:String = node.get("draworder");
    switch (d) {
      case "index":
        this.draworder = ObjectGroupDrawOrderIndex;
      case "topdown":
        this.draworder = ObjectGroupDrawOrderTopDown;
      default:
        this.draworder = ObjectGroupDrawOrderTopDown;
    }

    this.object = new Array<openfl.tiled.Object>();

    for (child in node) {
      if (child.nodeType != Xml.Element) {
        // skip non elements
        continue;
      }
      switch (child.nodeName) {
        case "properties":
          this.properties = new openfl.tiled.Properties(child);
        case "object":
          this.object.push(new openfl.tiled.Object(child, mMap));
      }
    }
  }

  /**
   * Update / render object group
   * @param offsetX
   * @param offsetY
   * @param index
   * @return Int
   */
  public function update(offsetX:Int, offsetY:Int, index:Int):Int {
    // initialize total
    var total:Int = 0;
    // iterate through objects
    for (object in this.object) {
      // call update of object method
      total += object.update(offsetX, offsetY, index + total);
    }
    // return total
    return total;
  }

  /**
   * Check for collision
   * @param x
   * @param y
   * @param width
   * @param height
   * @return Bool
   */
  public function collides(x:Int, y:Int, width:Int, height:Int):Bool {
    if (this.name != Helper.COLLISION_LAYER_NAME) {
      return false;
    }
    for (object in this.object) {
      // check for collision
      if (object.collides(x, y, width, height)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Helper to evaluate width
   * @return Int
   */
  public function evaluateWidth():Int {
    return 0;
  }

  /**
   * Helper to evaluate height
   * @return Int
   */
  public function evaluateHeight():Int {
    return 0;
  }
}
