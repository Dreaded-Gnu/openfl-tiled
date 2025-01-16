package openfl.tiled;

import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Rectangle;

class ImageLayer extends EventDispatcher implements openfl.tiled.Updatable {
  public var id(default, null):Int;
  public var name(default, null):String;
  public var klass(default, null):String;
  public var offsetx(default, null):Int;
  public var offsety(default, null):Int;
  public var parallaxx(default, null):Int;
  public var parallaxy(default, null):Int;
  public var x(default, null):Int;
  public var y(default, null):Int;
  public var opacity(default, null):Float;
  public var visible(default, null):Int;
  public var tintcolor(default, null):String;
  public var repeatx(default, null):Int;
  public var repeaty(default, null):Int;
  public var properties(default, null):openfl.tiled.Properties;
  public var image(default, null):openfl.tiled.Image;

  public var tileset(default, null):openfl.display.Tileset;
  public var tile(default, null):openfl.tiled.helper.AnimatedTile;

  private var mMap:openfl.tiled.Map;

  /**
   * Constructor
   * @param node
   * @param map
   */
  public function new(node:Xml, map:openfl.tiled.Map) {
    super();
    // cache map
    this.mMap = map;
    // parse attributes
    this.id = node.exists("id") ? Std.parseInt(node.get("id")) : 0;
    this.name = node.exists("name") ? node.get("name") : "";
    this.klass = node.exists("class") ? node.get("class") : "";
    this.offsetx = node.exists("offsetx") ? Std.parseInt(node.get("offsetx")) : 0;
    this.offsety = node.exists("offsety") ? Std.parseInt(node.get("offsety")) : 0;
    this.parallaxx = node.exists("parallaxx") ? Std.parseInt(node.get("parallaxx")) : 0;
    this.parallaxy = node.exists("parallaxy") ? Std.parseInt(node.get("parallaxy")) : 0;
    this.x = node.exists("x") ? Std.parseInt(node.get("x")) : 0;
    this.y = node.exists("y") ? Std.parseInt(node.get("y")) : 0;
    this.opacity = node.exists("opacity") ? Std.parseFloat(node.get("opacity")) : 0;
    this.visible = node.exists("visible") ? Std.parseInt(node.get("visible")) : 0;
    this.tintcolor = node.get("tintcolor");
    this.repeatx = node.exists("repeatx") ? Std.parseInt(node.get("repeatx")) : 0;
    this.repeaty = node.exists("repeaty") ? Std.parseInt(node.get("repeaty")) : 0;
    // parse children
    for (child in node) {
      if (child.nodeType != Xml.Element) {
        // skip non elements
        continue;
      }
      switch (child.nodeName) {
        case "properties":
          this.properties = new openfl.tiled.Properties(child);
        case "image":
          this.image = new openfl.tiled.Image(child, this.mMap);
      }
    }
  }

  /**
   * Load method
   */
  public function load():Void {
    if (this.image != null) {
      // register event listener
      this.image.addEventListener(Event.COMPLETE, onImageCompleted);
      // start loading
      this.image.load();
      // skip rest
      return;
    }
    // just dispatch complete event
    this.dispatchEvent(new Event(Event.COMPLETE));
  }

  /**
   * Callback for on image completed
   * @param event
   */
  private function onImageCompleted(event:Event):Void {
    // remove event listener
    this.image.removeEventListener(Event.COMPLETE, onImageCompleted);
    // parse image to tileset
    var rect:Array<Rectangle> = new Array<Rectangle>();
    rect.push(new Rectangle(0, 0, this.image.width, this.image.height));
    this.tileset = new openfl.display.Tileset(this.image.bitmap.bitmapData, rect);
    // build tile
    this.tile = new openfl.tiled.helper.AnimatedTile(0, this.x, this.y, 1, 1, 0, null, this.mMap);
    // set tileset
    this.tile.tileset = this.tileset;
    // fire complete event
    this.dispatchEvent(new Event(Event.COMPLETE));
  }

  /**
   * Render method
   * @param offsetX
   * @param offsetY
   * @param index
   */
  public function update(offsetX:Int, offsetY:Int, index:Int):Int {
    // handle null, which shouldn't happen at all
    if (this.tile == null) {
      return 0;
    }
    // apply x / y offset
    this.tile.x = this.x - offsetX;
    this.tile.y = this.y - offsetY;
    // cache tilemap locally
    var tilemap:openfl.display.Tilemap = this.mMap.tilemap;
    // check if won't be visible
    if (!this.mMap.willBeVisible(Std.int(this.tile.x), Std.int(this.tile.y), this.image.width, this.image.height)) {
      // check if it was added
      if (tilemap.contains(this.tile)) {
        // remove it since it isn't visible any longer
        tilemap.removeTile(this.tile);
      }
      // skip rest
      return 0;
    }
    // add tile to tilemap
    tilemap.addTileAt(this.tile, index);
    // return total
    return 1;
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
