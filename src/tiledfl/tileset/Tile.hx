package tiledfl.tileset;

import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Rectangle;

/**
 * Tiled tile representation
 */
class Tile extends EventDispatcher {
  /**
   * Tile id
   */
  public var id(default, null):Int;

  /**
   * Tile type
   */
  public var type(default, null):String;

  /**
   * Tile terrain
   */
  public var terrain(default, null):String;

  /**
   * Tile probability
   */
  public var probability(default, null):Float;

  /**
   * Tile x coordinate
   */
  public var x(default, null):Int;

  /**
   * Tile y coordinate
   */
  public var y(default, null):Int;

  /**
   * Tile width
   */
  public var width(default, null):Int;

  /**
   * Tile height
   */
  public var height(default, null):Int;

  /**
   * Tile properties
   */
  public var properties(default, null):tiledfl.Properties;

  /**
   * Image of the tile
   */
  public var image(default, null):tiledfl.Image;

  /**
   * Object group
   */
  public var objectgroup(default, null):tiledfl.ObjectGroup;

  /**
   * Animation
   */
  public var animation(default, null):tiledfl.tileset.Animation;

  /**
   * Used and created openfl tileset
   */
  public var tileset(default, null):openfl.display.Tileset;

  private var mMap:tiledfl.Map;

  /**
   * Constructor
   * @param node xml representation to parse
   * @param map map the tile belongs to
   */
  public function new(node:Xml, map:tiledfl.Map) {
    super();
    this.mMap = map;
    // parse properties
    this.id = Std.parseInt(node.get("id"));
    this.type = node.exists("type") ? node.get("type") : "";
    this.terrain = node.get("terrain");
    this.probability = node.exists("probability") ? Std.parseFloat(node.get("probability")) : 0;
    this.x = node.exists("x") ? Std.parseInt(node.get("x")) : 0;
    this.y = node.exists("y") ? Std.parseInt(node.get("y")) : 0;
    this.width = node.exists("width") ? Std.parseInt(node.get("width")) : -1;
    this.height = node.exists("height") ? Std.parseInt(node.get("height")) : -1;
    // parse children
    for (child in node) {
      if (child.nodeType != Xml.Element) {
        continue;
      }
      switch (child.nodeName) {
        case "properties":
          this.properties = new tiledfl.Properties(child);
        case "image":
          this.image = new tiledfl.Image(child, this.mMap);
        case "objectgroup":
          this.objectgroup = new tiledfl.ObjectGroup(child, this.mMap);
        case "animation":
          this.animation = new tiledfl.tileset.Animation(child);
      }
    }
  }

  /**
   * Load async image if necessary stuff
   */
  @:dox(hide) @:noCompletion public function load():Void {
    if (this.image != null) {
      this.image.addEventListener(Event.COMPLETE, onImageCompleted);
      this.image.load();
    } else {
      this.dispatchEvent(new Event(Event.COMPLETE));
    }
  }

  /**
   * Callback for on image completed
   * @param event
   */
  private function onImageCompleted(event:Event):Void {
    this.image.removeEventListener(Event.COMPLETE, onImageCompleted);
    // parse image to tileset
    var rect:Array<Rectangle> = new Array<Rectangle>();
    rect.push(new Rectangle(this.x, this.y, this.width, this.height));
    this.tileset = new openfl.display.Tileset(this.image.bitmap.bitmapData, rect);
    // fire complete event
    this.dispatchEvent(new Event(Event.COMPLETE));
  }
}
