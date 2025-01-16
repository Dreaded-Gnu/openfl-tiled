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

  private var mTileCheckContainer:std.Map<Int, std.Map<Int, openfl.tiled.helper.AnimatedTile>>;
  private var mMap:openfl.tiled.Map;

  /**
   * Constructor
   * @param node
   * @param map
   */
  public function new(node:Xml, map:openfl.tiled.Map) {
    this.mMap = map;
    this.mTileCheckContainer = new std.Map<Int, std.Map<Int, openfl.tiled.helper.AnimatedTile>>();
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
   * @param tileIndex
   * @param mapIndex
   * @return Int
   */
  private function renderObject(object:openfl.tiled.Object, offsetX:Int, offsetY:Int, tileIndex:Int, mapIndex:Int):Int {
    var gid:Int = object.gid;
    // handle invalid
    if (0 == gid) {
      return 0;
    }
    // get tileset
    var tileset:openfl.tiled.Tileset = this.mMap.tilesetByGid(gid);
    if (null == tileset) {
      return 0;
    }
    // subtract first gid from tileset
    gid -= tileset.firstgid;
    // create tilemap if not existing
    if (null == this.mTileCheckContainer.get(tileset.firstgid)) {
      this.mTileCheckContainer.set(tileset.firstgid, new std.Map<Int, openfl.tiled.helper.AnimatedTile>());
    }
    var ts:openfl.display.Tileset = tileset.tileset;
    var tile:openfl.tiled.tileset.Tile = tileset.getTileByGid(gid);
    if (tile?.tileset != null) {
      ts = tile.tileset;
    }
    // generate tile
    var t:openfl.tiled.helper.AnimatedTile = null;
    // get tile container for checking
    var map:std.Map<Int, openfl.tiled.helper.AnimatedTile> = this.mTileCheckContainer.get(tileset.firstgid);
    // handle already set
    if (map.exists(mapIndex)) {
      t = map.get(mapIndex);
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
      // apply flipping
      openfl.tiled.Helper.applyTileFlipping(this.mMap, t, object, tileset);
    } else {
      t = new openfl.tiled.helper.AnimatedTile( // gid
        tile?.tileset != null ? 0 : gid, // x / y position
        object.x - tileset.tileoffset.x,
        object.y - tileset.tileoffset.y - object.height, // scaling depending on object size
        object.width / (tile?.tileset != null ? tile.width : tileset.tilewidth), object.height / (tile?.tileset != null ? tile.height : tileset.tileheight),
        0, tileset.tile[gid]?.animation, this.mMap);
      // set tileset
      t.tileset = ts;
      // apply flipping
      openfl.tiled.Helper.applyTileFlipping(this.mMap, t, object, tileset);
    }
    // cache tilemap locally
    var tilemap:openfl.display.Tilemap = this.mMap.tilemap;
    // adjust x and y of tile
    t.x -= offsetX;
    t.y -= offsetY;
    // add tile at position
    if (!map.exists(mapIndex)) {
      // add to check container
      map.set(mapIndex, t);
    }
    // skip coordinate if not visible
    if (!this.mMap.willBeVisible(Std.int(t.x), Std.int(t.y), Std.int(object.width * t.scaleX), Std.int(object.height * t.scaleY))) {
      // check if it's displayed
      if (tilemap.contains(t)) {
        // just remove it from map
        tilemap.removeTile(t);
      }
      // skip rest
      return 0;
    }
    // add tile to tilemap
    tilemap.addTileAt(t, tileIndex);
    // return one added tile
    return 1;
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
      // try to render and increment total
      this.renderObject(object, offsetX, offsetY, index + total, total++);
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
