package openfl.tiled.tileset;

import openfl.events.EventDispatcher;
import openfl.events.Event;

class Tile extends EventDispatcher {
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

  private var mMap:openfl.tiled.Map;

  /**
   * Constructor
   * @param node
   * @param map
   */
  public function new(node:Xml, map:openfl.tiled.Map) {
    // call parent constructor
    super();
    this.mMap = map;
    // parse properties
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
          this.image = new openfl.tiled.Image(child, this.mMap);
        case "objectgroup":
        case "animation":
      }
    }
  }

  /**
   * Load async necessary stuff
   */
  public function load() {
    if (this.image != null) {
      // add complete listener
      this.image.addEventListener(Event.COMPLETE, onImageCompleted);
      // load image
      this.image.load();
    } else {
      // dispatch succeeded event
      this.dispatchEvent(new Event(Event.COMPLETE));
    }
  }

  /**
   * Callback for on image completed
   * @param event
   */
  private function onImageCompleted(event:Event):Void {
    // remove event listener
    this.image.removeEventListener(Event.COMPLETE, onImageCompleted);
    // fire complete event
    this.dispatchEvent(new Event(Event.COMPLETE));
  }
}
