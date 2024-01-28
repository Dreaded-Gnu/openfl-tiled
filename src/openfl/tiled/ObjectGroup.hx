package openfl.tiled;

import openfl.errors.Error;
import openfl.display.Sprite;

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

  private var mTilemapData:std.Map<Int, openfl.display.TileContainer>;
  private var mMap:openfl.tiled.Map;
  private var mPreviousX:Int;
  private var mPreviousY:Int;

  /**
   * Constructor
   * @param node
   * @param map
   */
  public function new(node:Xml, map:openfl.tiled.Map) {
    this.mMap = map;
    this.mTilemapData = new std.Map<Int, openfl.display.TileContainer>();
    this.mPreviousX = 0;
    this.mPreviousY = 0;
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
   * Helper to render object
   * @param object
   * @param offsetX
   * @param offsetY
   * @param index
   */
  private function renderObject(object:openfl.tiled.Object, offsetX:Int, offsetY:Int, index:Int):Void {
    var gid:Int = object.gid;
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
    // create tilemap if not existing
    if (null == mTilemapData.get(tileset.firstgid)) {
      var tc:openfl.display.TileContainer = new openfl.display.TileContainer(0, 0);
      tc.alpha = this.opacity;
      tc.visible = 1 == this.visible;
      mTilemapData.set(tileset.firstgid, tc);
    }
    var ts:openfl.display.Tileset = tileset.tileset;
    var tile:openfl.tiled.tileset.Tile = tileset.getTileByGid(gid);
    if (tile?.tileset != null) {
      ts = tile.tileset;
    }
    // generate tile
    var t:openfl.tiled.helper.AnimatedTile = null;
    if (mTilemapData.get(tileset.firstgid).getTileAt(index) != null) {
      t = cast(mTilemapData.get(tileset.firstgid).getTileAt(index), openfl.tiled.helper.AnimatedTile);
      // gid
      t.id = tile?.tileset != null ? 0 : gid;
      // x / y position
      t.x = object.x - tileset.tileoffset.x;
      t.y = object.y - tileset.tileoffset.y - object.height;
      // scaling depending on object size
      t.scaleX = object.width / (tile?.tileset != null ? tile.width : tileset.tilewidth);
      t.scaleY = object.height / (tile?.tileset != null ? tile.height : tileset.tileheight);
      t.rotation = 0;
      t.animation = tileset.tile[gid]?.animation;
      t.tileset = ts;
      t.map = this.mMap;
    } else {
      t = new openfl.tiled.helper.AnimatedTile( // gid
        tile?.tileset != null ? 0 : gid, // x / y position
        object.x - tileset.tileoffset.x,
        object.y - tileset.tileoffset.y - object.height, // scaling depending on object size
        object.width / (tile?.tileset != null ? tile.width : tileset.tilewidth),
        object.height / (tile?.tileset != null ? tile.height : tileset.tileheight), 0, tileset.tile[gid]?.animation, this.mMap);
      t.tileset = ts;
    }
    // add tile at position
    if (mTilemapData.get(tileset.firstgid).getTileAt(index) == null) {
      mTilemapData.get(tileset.firstgid).addTileAt(t, index);
    }
  }

  /**
   * Update / render object group
   * @param tilemap
   * @param offsetX
   * @param offsetY
   * @param previousOffsetX
   * @param previousOffsetY
   */
  public function update(tilemap:openfl.display.Tilemap, offsetX:Int, offsetY:Int, previousOffsetX:Int, previousOffsetY:Int):Void {
    var index:Int = 0;
    for (object in this.object) {
      this.renderObject(object, offsetX, offsetY, index++);
    }
    // apply data to tilemap
    for (tm in this.mTilemapData) {
      if (offsetX != this.mPreviousX) {
        tm.x = tm.x + previousOffsetX - offsetX;
      }
      if (offsetY != this.mPreviousY) {
        tm.y = tm.y + previousOffsetY - offsetY;
      }
      // add to tilemap
      if (!tilemap.contains(tm)) {
        tilemap.addTile(tm);
      }
    }
    // set new previous
    this.mPreviousX = offsetX;
    this.mPreviousY = offsetY;
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
}
