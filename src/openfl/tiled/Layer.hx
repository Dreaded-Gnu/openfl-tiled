package openfl.tiled;

import openfl.geom.ColorTransform;
import openfl.errors.Error;
import openfl.tiled.map.RenderOrder;
import openfl.display.Tile;
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
  public function render(displayObject:Sprite, offsetX:Int, offsetY:Int):Void {
    if (1 != this.visible) {
      return;
    }

    var tilesetData:std.Map<Int, openfl.display.Tileset> =
      new std.Map<Int, openfl.display.Tileset>();
    var tilemapData:std.Map<Int, openfl.display.Tilemap> =
      new std.Map<Int, openfl.display.Tilemap>();
    // render layers
    switch (this.mMap.renderorder) {
      case RenderOrder.MapRenderOrderRightDown:
        for (x in 0...this.width) {
          for (y in 0...this.height) {
            // calculate array position depending on x / y
            var id:Int = this.mMap.width * x + y;
            // get gid
            var gid:Int = this.data.tile[id].gid;
            // handle invalid
            if (0 == gid) {
              continue;
            }
            // get tileset
            var tileset:openfl.tiled.Tileset = this.mMap.tilesetByGid(gid);
            if (null == tileset) {
              continue;
            }
            // subtract first gid from tileset
            gid -= tileset.firstgid;

            if (null == tilesetData.get(gid)) {
              var txlen:Int = Std.int(tileset.image.width / tileset.tilewidth);
              var tylen:Int = Std.int(tileset.image.height / tileset.tileheight);
              var rect:Array<Rectangle> = new Array<Rectangle>();
              for (ty in 0...tylen) {
                for (tx in 0...txlen) {
                  rect.push(
                    new Rectangle(
                      tx * tileset.tilewidth,
                      ty * tileset.tileheight,
                      tileset.tilewidth,
                      tileset.tileheight
                    )
                  );
                }
              }
              var ts:openfl.display.Tileset = new openfl.display.Tileset(
                tileset.image.bitmap.bitmapData,
                rect
              );
              var tm:openfl.display.Tilemap = new openfl.display.Tilemap(
                this.width * tileset.tilewidth,
                this.height * tileset.tileheight,
                ts
              );
              tm.alpha = this.opacity;
              //tm.opaqueBackground = tileset.image.trans;
              tm.tileColorTransformEnabled = true;
              tilesetData.set(gid, ts);
              tilemapData.set(gid, tm);
            }
            var t:openfl.display.Tile = new openfl.display.Tile(
              gid,
              y * this.mMap.tileheight + offsetY,
              x * this.mMap.tilewidth + offsetX
            );
            // add tile at position
            tilemapData.get(gid).addTile(t);
          }
        }
      case RenderOrder.MapRenderOrderRightUp:
        throw new Error('Unsupported');
      case RenderOrder.MapRenderOrderLeftDown:
        throw new Error('Unsupported');
      case RenderOrder.MapRenderOrderLeftUp:
        throw new Error('Unsupported');
    }

    // add display objects
    for(tm in tilemapData) {
      displayObject.addChild(tm);
    }
  }
}
