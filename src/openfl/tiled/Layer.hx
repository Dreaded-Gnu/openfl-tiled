package openfl.tiled;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.display.Sprite;

class Layer {
  public var id(default, null):Int;
  public var name(default, null):String;
  public var klass(default, null):String;
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
  public var properties(default, null):openfl.tiled.Properties;
  public var data(default, null):openfl.tiled.layer.Data;

  private var mMap:openfl.tiled.Map;

  /**
   * Constructor
   * @param node
   * @param map
   * @param layerId
   */
  public function new(node:Xml, map:openfl.tiled.Map, layerId:Int) {
    // set map
    this.mMap = map;
    // parse stuff
    this.id = node.exists("id")
      ? Std.parseInt(node.get("id"))
      : layerId;
    this.name = node.get("name");
    this.klass = node.exists("class") ? node.get("class") : "";
    this.x = node.exists("x") ? Std.parseInt(node.get("x")) : 0;
    this.y = node.exists("y") ? Std.parseInt(node.get("y")) : 0;
    this.width = Std.parseInt(node.get("width"));
    this.height = Std.parseInt(node.get("height"));
    this.opacity = node.exists("opacity")
      ? Std.parseFloat(node.get("opacity"))
      : 1;
    this.visible = node.exists("visible")
      ? Std.parseInt(node.get("visible"))
      : 1;
    this.tintcolor = node.get("tintcolor");
    this.offsetx = node.exists("offsetx")
      ? Std.parseInt(node.get("offsetx"))
      : 0;
    this.offsety = node.exists("offsety")
      ? Std.parseInt(node.get("offsety"))
      : 0;
    this.parallaxx = node.exists("parallaxx")
      ? Std.parseInt(node.get("parallaxx"))
      : 1;
    this.parallaxy = node.exists("parallaxy")
      ? Std.parseInt(node.get("parallaxy"))
      : 1;
    // parse children
    for (child in node) {
      // skip non elements
      if (child.nodeType != Xml.Element) {
        continue;
      }
      switch (child.nodeName) {
        case "data":
          this.data = new openfl.tiled.layer.Data(child);
        case "properties":
      }
    }
  }

  /**
   * Render layer position x / y
   * @param displayObject
   * @param x
   * @param y
   */
  public function render(displayObject:Sprite, x:Int, y:Int, offsetX:Int, offsetY:Int):Void {
    // calculate array position depending on x / y
    var id:Int = this.mMap.width * x + y;
    // get gid
    var gid:Int = this.data.tile[id].gid;
    // handle invalid
    if (0 == gid) {
      return;
    }
    // get tileset
    var tileset:openfl.tiled.Tileset = this.mMap.tilesetByGid(gid);
    if (null == tileset) {
      return;
    }
    // subtract first gid from tileset
    gid -= tileset.firstgid;
    // extract pixels
    var pixels = tileset.image.bitmap.bitmapData.getPixels(new Rectangle(
      Std.int(gid % Std.int(tileset.image.width / tileset.tilewidth)) * tileset.tilewidth,
      Std.int(gid / Std.int(tileset.image.width / tileset.tilewidth)) * tileset.tileheight,
      tileset.tilewidth,
      tileset.tileheight
    ));
    // generate new bitmap data
    var bitmapData:BitmapData = new BitmapData(tileset.tilewidth, tileset.tileheight);
    // set pixels
    bitmapData.setPixels(new Rectangle(0, 0, tileset.tilewidth, tileset.tileheight), pixels);
    // create new bitmap
    var bitmap:Bitmap = new Bitmap(bitmapData);
    // set x and y position
    bitmap.y = x * this.mMap.tilewidth + offsetX;
    bitmap.x = y * this.mMap.tileheight + offsetY;
    bitmap.alpha = this.opacity;
    //bitmap.opaqueBackground = tileset.image.trans;
    // add as child to display object
    displayObject.addChild(bitmap);
  }
}
