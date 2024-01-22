package openfl.tiled.tileset;

class Tile {
  public var id(default, null):Int;
  public var type(default, null):String;
  public var terrain(default, null):String;
  public var probability(default, null):Float;
  public var x(default, null):Int;
  public var y(default, null):Int;
  public var width(default, null):Int;
  public var height(default, null):Int;
  public var properties(default, null):openfl.tiled.Properties;
  public var image(default, null):openfl.tiled.Image;
  public var objectgroup(default, null):openfl.tiled.ObjectGroup;
  public var animation(default, null):openfl.tiled.tileset.Animation;

  public function new(node:Xml) {
    this.id = Std.parseInt(node.get("id"));
    this.type = node.exists("type") ? node.get("type") : "";
    this.terrain = node.get("terrain");
    this.probability = node.exists("probability")
      ? Std.parseFloat(node.get("probability"))
      : 0;
    this.x = node.exists("x") ? Std.parseInt(node.get("x")) : 0;
    this.y = node.exists("y") ? Std.parseInt(node.get("y")) : 0;
    this.width = node.exists("width")
      ? Std.parseInt(node.get("width"))
      : -1;
    this.height = node.exists("height")
      ? Std.parseInt(node.get("height"))
      : -1;
    // parse children
    for (child in node) {
      if (child.nodeType != Xml.Element) {
        continue;
      }
      switch (child.nodeName) {
        case "properties":
          this.properties = new openfl.tiled.Properties(child);
        case "image":
        case "objectgroup":
        case "animation":
      }
    }
  }
}
