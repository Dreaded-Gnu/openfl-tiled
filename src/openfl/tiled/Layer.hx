package openfl.tiled;

import haxe.DynamicAccess;
import openfl.errors.Error;
import openfl.tiled.map.RenderOrder;

class Layer implements openfl.tiled.Updatable {
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

  private var mTilemapData:std.Map<Int, openfl.display.TileContainer>;
  private var mTileCheckContainer:std.Map<Int, Dynamic>;
  private var mMap:openfl.tiled.Map;
  private var mPreviousX:Int;
  private var mPreviousY:Int;

  /**
   * Constructor
   * @param node
   * @param map
   * @param layerId
   */
  public function new(node:Xml, map:openfl.tiled.Map, layerId:Int) {
    this.mMap = map;
    this.mTilemapData = new std.Map<Int, openfl.display.TileContainer>();
    this.mTileCheckContainer = new std.Map<Int, Dynamic>();
    this.mPreviousX = 0;
    this.mPreviousY = 0;
    // parse stuff
    this.id = node.exists("id") ? Std.parseInt(node.get("id")) : layerId;
    this.name = node.get("name");
    this.klass = node.exists("class") ? node.get("class") : "";
    this.x = node.exists("x") ? Std.parseInt(node.get("x")) : 0;
    this.y = node.exists("y") ? Std.parseInt(node.get("y")) : 0;
    this.width = Std.parseInt(node.get("width"));
    this.height = Std.parseInt(node.get("height"));
    this.opacity = node.exists("opacity") ? Std.parseFloat(node.get("opacity")) : 1;
    this.visible = node.exists("visible") ? Std.parseInt(node.get("visible")) : 1;
    this.tintcolor = node.get("tintcolor");
    this.offsetx = node.exists("offsetx") ? Std.parseInt(node.get("offsetx")) : 0;
    this.offsety = node.exists("offsety") ? Std.parseInt(node.get("offsety")) : 0;
    this.parallaxx = node.exists("parallaxx") ? Std.parseInt(node.get("parallaxx")) : 1;
    this.parallaxy = node.exists("parallaxy") ? Std.parseInt(node.get("parallaxy")) : 1;
    // parse children
    for (child in node) {
      if (child.nodeType != Xml.Element) {
        // skip non elements
        continue;
      }
      switch (child.nodeName) {
        case "data":
          this.data = new openfl.tiled.layer.Data(child);
        case "properties":
          this.properties = new openfl.tiled.Properties(child);
      }
    }
  }

  /**
   * Internal helper to render layer
   * @param x
   * @param y
   */
  private function renderLayer(x:Int, y:Int):Void {
    var id:Int = x + y * this.mMap.width;
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
    // generate tile
    var t:openfl.tiled.helper.AnimatedTile = this.generateTile(x, y, id, gid, tileset);
    // get dynamic access for checking
    var da:DynamicAccess<Dynamic> = this.mTileCheckContainer.get(tileset.firstgid);
    // add tile at position
    if (da.get(Std.string(id)) == null) {
      // add tile
      this.mTilemapData.get(tileset.firstgid).addTileAt(t, id);
      // set item
      da.set(Std.string(id), t);
    }
  }

  /**
   * Helper to render chunk to tilemap and return greatest global index
   * @param chunk
   * @param chunkIndex
   * @return Void
   */
  private function renderChunk(chunk:openfl.tiled.layer.Chunk, chunkIndex:Int):Void {
    // calculate max to iterate to
    var max:Int = chunk.width * chunk.height;
    // iterate from max to min
    for (i in 0...max) {
      // calculate x and y
      var x:Int = Std.int(i % chunk.width);
      var y:Int = Std.int(i / chunk.height);
      // calculate id
      var id:Int = x + y * chunk.width;
      // get gid of current id
      var gid:Int = chunk.tile[id].gid;
      // handle invalid
      if (0 == gid) {
        continue;
      }
      // get tileset
      var tileset:openfl.tiled.Tileset = this.mMap.tilesetByGid(gid);
      if (null == tileset) {
        continue;
      }
      // generate tile
      var t:openfl.tiled.helper.AnimatedTile = this.generateTile(x, y, id, gid, tileset, chunk, chunkIndex);
      // get dynamic access for checking
      var da:DynamicAccess<Dynamic> = this.mTileCheckContainer.get(chunkIndex);
      // add tile at position
      if (da.get(Std.string(id)) == null) {
        // add tile
        this.mTilemapData.get(chunkIndex).addTileAt(t, id);
        // set item
        da.set(Std.string(id), t);
      }
    }
  }

  /**
   * Helper to generate a tile to add
   * @param x
   * @param y
   * @param id
   * @param gid
   * @param tileset
   * @param chunk
   * @return openfl.tiled.helper.AnimatedTile
   */
  private function generateTile(x:Int, y:Int, id:Int, gid:Int, tileset:openfl.tiled.Tileset, chunk:openfl.tiled.layer.Chunk = null,
      chunkIndex:Int = -1):openfl.tiled.helper.AnimatedTile {
    // subtract first gid from tileset
    gid -= tileset.firstgid;
    if (null == this.mTilemapData.get(chunkIndex != -1 ? chunkIndex : tileset.firstgid)) {
      var tc:openfl.display.TileContainer = null;
      if (chunk != null) {
        if (this.mMap.orientation == MapOrientationIsometric || this.mMap.orientation == MapOrientationStaggered) {
          tc = new openfl.display.TileContainer((x + chunk.x) * this.mMap.tilewidth, (y + chunk.y) * this.mMap.tileheight / 2,);
        } else {
          tc = new openfl.display.TileContainer((x + chunk.x) * tileset.tilewidth, (y + chunk.y) * tileset.tileheight,);
        }
      } else {
        tc = new openfl.display.TileContainer(this.x * tileset.tilewidth, this.y * tileset.tileheight);
      }
      tc.alpha = this.opacity;
      tc.visible = 1 == this.visible;
      if (chunkIndex != -1) {
        this.mTilemapData.set(chunkIndex, tc);
        this.mTileCheckContainer.set(chunkIndex, {});
      } else {
        this.mTilemapData.set(tileset.firstgid, tc);
        this.mTileCheckContainer.set(tileset.firstgid, {});
      }
    }
    var ts:openfl.display.Tileset = tileset.tileset;
    var tile:openfl.tiled.tileset.Tile = tileset.getTileByGid(gid);
    if (tile?.tileset != null) {
      ts = tile.tileset;
    }
    // generate tile
    var t:openfl.tiled.helper.AnimatedTile = null;
    switch (this.mMap.orientation) {
      case MapOrientationIsometric, MapOrientationStaggered:
        if (mTilemapData.get(chunkIndex != -1 ? chunkIndex : tileset.firstgid).getTileAt(id) != null) {
          t = cast mTilemapData.get(chunkIndex != -1 ? chunkIndex : tileset.firstgid).getTileAt(id);
          // gid
          t.id = tile?.tileset != null ? 0 : gid;
          // x / y position
          t.x = (x - y) * (tileset.tilewidth / 2);
          t.y = (x + y) * (tileset.tileheight / 2);
          // scaling depending on object size
          t.scaleX = 1;
          t.scaleY = 1;
          t.rotation = 0;
          t.animation = tileset.tile[gid]?.animation;
          t.map = this.mMap;
        } else {
          t = new openfl.tiled.helper.AnimatedTile(tile?.tileset != null ? 0 : gid, (x - y) * (tileset.tilewidth / 2), (x + y) * (tileset.tileheight / 2), 1,
            1, 0, tileset.tile[gid]?.animation, this.mMap);
        }
        t.tileset = ts;
        if (this.mMap.orientation == MapOrientationStaggered) {
          t.x = x * tileset.tilewidth;
          t.y = y * tileset.tileheight;
          if (this.mMap.staggeraxis == MapStaggerAxisY) {
            t.y = Std.int(t.y / 2);
            if (this.mMap.staggerindex == MapStaggerIndexOdd) {
              t.x += Std.int((y & 1) * tileset.tilewidth / 2);
            } else if (this.mMap.staggerindex == MapStaggerIndexEven) {
              t.x -= Std.int((y & 1) * tileset.tilewidth / 2);
            }
          } else if (this.mMap.staggeraxis == MapStaggerAxisX) {
            t.x = Std.int(t.x / 2);
            if (this.mMap.staggerindex == MapStaggerIndexOdd) {
              t.y += Std.int((x & 1) * tileset.tileheight / 2);
            } else if (this.mMap.staggerindex == MapStaggerIndexEven) {
              t.y -= Std.int((x & 1) * tileset.tileheight / 2);
            }
          }
        } else {
          t.x += this.mMap.width / 2 * tileset.tilewidth;
        } // apply position correction when tileheight is greater than tilemap
        if (tileset.tileheight > this.mMap.tileheight) {
          t.y = Std.int(t.y / (tileset.tileheight / this.mMap.tileheight));
        }
        if (tileset.tilewidth > this.mMap.tilewidth) {
          t.x = Std.int(t.x / (tileset.tilewidth / this.mMap.tilewidth));
        } // apply tileoffset
        t.x -= tileset.tileoffset.x;
        t.y -= tileset.tileoffset.y;
      case MapOrientationOrthogonal:
        if (mTilemapData.get(chunkIndex != -1 ? chunkIndex : tileset.firstgid).getTileAt(id) != null) {
          t = cast mTilemapData.get(chunkIndex != -1 ? chunkIndex : tileset.firstgid).getTileAt(id);
          // gid
          t.id = tile?.tileset != null ? 0 : gid;
          // x / y position
          t.x = x * this.mMap.tilewidth;
          t.y = y * this.mMap.tileheight;
          // scaling depending on object size
          t.scaleX = 1;
          t.scaleY = 1;
          t.rotation = 0;
          t.animation = tileset.tile[gid]?.animation;
          t.map = this.mMap;
        } else {
          t = new openfl.tiled.helper.AnimatedTile(tile?.tileset != null ? 0 : gid, x * this.mMap.tilewidth, y * this.mMap.tileheight, 1, 1, 0,
            tileset.tile[gid]?.animation, this.mMap);
        }
        t.tileset = ts;
        if (tile?.tileset != null) {
          var rect:openfl.geom.Rectangle = ts.getRect(0);
          if (rect.height > this.mMap.tileheight) {
            t.y -= rect.height / Std.int(rect.height / this.mMap.tileheight);
          }
          /*if (rect.width > this.mMap.tilewidth) {
            t.x -= rect.width / Std.int(rect.width / this.mMap.tilewidth);
          }*/
        } else {
          // apply position correction when tileheight is greater than tilemap tileheight
          if (tileset.tileheight > this.mMap.tileheight) {
            t.y -= tileset.tileheight / Std.int(tileset.tileheight / this.mMap.tileheight);
          }
          /*if (tileset.tilewidth > this.mMap.tilewidth) {
            t.x -= tileset.tilewidth / Std.int(tileset.tilewidth / this.mMap.tilewidth);
          }*/
        }
        // apply tileoffset
        t.x -= tileset.tileoffset.x;
        t.y -= tileset.tileoffset.y;
      case MapOrientationHexagonal:
        if (mTilemapData.get(chunkIndex != -1 ? chunkIndex : tileset.firstgid).getTileAt(id) != null) {
          t = cast mTilemapData.get(chunkIndex != -1 ? chunkIndex : tileset.firstgid).getTileAt(id);
          // gid
          t.id = tile?.tileset != null ? 0 : gid;
          // x / y position
          t.x = x * this.mMap.tilewidth;
          t.y = y * this.mMap.tileheight;
          // scaling depending on object size
          t.scaleX = 1;
          t.scaleY = 1;
          t.rotation = 0;
          t.animation = tileset.tile[gid]?.animation;
          t.map = this.mMap;
        } else {
          t = new openfl.tiled.helper.AnimatedTile(tile?.tileset != null ? 0 : gid, x * this.mMap.tilewidth, y * this.mMap.tileheight, 1, 1, 0,
            tileset.tile[gid]?.animation, this.mMap);
        }
        t.tileset = ts;
        if (this.mMap.staggeraxis == MapStaggerAxisY) {
          var adjustX:Int = 0;
          if (this.mMap.staggerindex == MapStaggerIndexEven) {
            if (0 != (y + 1) % 2) {
              adjustX = this.mMap.hexsidelength;
            }
          } else if (this.mMap.staggerindex == MapStaggerIndexOdd) {
            if (0 == (y + 1) % 2) {
              adjustX = this.mMap.hexsidelength;
            }
          }
          t.y -= (this.mMap.hexsidelength / 2) * y;
          t.x += adjustX;
        } else if (this.mMap.staggeraxis == MapStaggerAxisX) {
          var adjustY:Int = 0;
          if (this.mMap.staggerindex == MapStaggerIndexEven) {
            if (0 != (y + 1) % 2) {
              adjustY = this.mMap.hexsidelength;
            }
          } else if (this.mMap.staggerindex == MapStaggerIndexOdd) {
            if (0 == (y + 1) % 2) {
              adjustY = this.mMap.hexsidelength;
            }
          }
          t.y += adjustY;
          t.x -= (this.mMap.hexsidelength / 2) * x;
        } // apply tileoffset
        t.x -= tileset.tileoffset.x;
        t.y -= tileset.tileoffset.y;
    }
    return t;
  }

  /**
   * Render a layer to tilemap
   * @param tilemap
   * @param offsetX
   * @param offsetY
   */
  public function update(tilemap:openfl.display.Tilemap, offsetX:Int, offsetY:Int):Void {
    switch (this.mMap.renderorder) {
      case RenderOrder.MapRenderOrderRightDown:
        if (this.mMap.infinite == 1) {
          var chunkIdx:Int = 0;
          // render chunk by chunk
          for (chunk in this.data.chunk) {
            this.renderChunk(chunk, chunkIdx);
            chunkIdx++;
          }
        } else {
          var max:Int = this.width * this.height;
          for (i in 0...max) {
            // calculate x and y
            var x:Int = Std.int(i % width);
            var y:Int = Std.int(i / height);
            // call render layer
            this.renderLayer(x, y);
          }
        }
      case RenderOrder.MapRenderOrderRightUp:
        throw new Error('Unsupported render order right-up');
      case RenderOrder.MapRenderOrderLeftDown:
        throw new Error('Unsupported render order left-down');
      case RenderOrder.MapRenderOrderLeftUp:
        throw new Error('Unsupported render order left-up');
    }

    for (tm in this.mTilemapData) {
      if (offsetX != this.mPreviousX) {
        tm.x = tm.x + this.mPreviousX - offsetX;
      }
      if (offsetY != this.mPreviousY) {
        tm.y = tm.y + this.mPreviousY - offsetY;
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
   * Helper to get tile id at
   * @param x
   * @param y
   * @return Int
   */
  private function getTileGidAt(x:Int, y:Int):Int {
    // handle non infinite maps
    if (this.mMap.infinite != 1) {
      var id:Int = Std.int(y / this.mMap.tileheight) * this.mMap.width + Std.int(x / this.mMap.tilewidth);
      // handle not set
      if (null == this.data.tile[id]) {
        return 0;
      }
      // get gid
      var gid:Int = this.data.tile[id].gid;
      // handle invalid
      if (0 == gid) {
        return 0;
      }
      // get tileset
      var tileset:openfl.tiled.Tileset = this.mMap.tilesetByGid(gid);
      if (null == tileset) {
        return 0;
      }
      return gid;
    }
    // handle infinite maps
    for (chunk in this.data.chunk) {
      // check if chunk is affected
      if (!(chunk.x * this.mMap.tilewidth <= x
        && chunk.x * this.mMap.tilewidth + this.mMap.tilewidth * chunk.width > x
        && chunk.y * this.mMap.tileheight <= y
        && chunk.y * this.mMap.tileheight + this.mMap.tileheight * chunk.height > y)) {
        continue;
      }
      var realX:Int = x - chunk.x * this.mMap.tilewidth;
      var realY:Int = y - chunk.y * this.mMap.tileheight;
      // get id
      var id:Int = Std.int(realY / this.mMap.tileheight) * chunk.width + Std.int(realX / this.mMap.tilewidth);
      // get gid
      var gid:Int = chunk.tile[id].gid;
      // handle invalid
      if (0 == gid) {
        return 0;
      }
      // get tileset
      var tileset:openfl.tiled.Tileset = this.mMap.tilesetByGid(gid);
      if (null == tileset) {
        return 0;
      }
      return gid;
    }
    // nothing found, return null
    return 0;
  }

  /**
   * Helper to get tile at x/y coordinate
   * @param x
   * @param y
   * @return openfl.tiled.tileset.Tile
   */
  private function getTileAt(x:Int, y:Int):openfl.tiled.tileset.Tile {
    // handle non infinite maps
    if (this.mMap.infinite != 1) {
      var id:Int = Std.int(y / this.mMap.tileheight) * this.mMap.width + Std.int(x / this.mMap.tilewidth);
      // handle not set
      if (null == this.data.tile[id]) {
        return null;
      }
      // get gid
      var gid:Int = this.data.tile[id].gid;
      // handle invalid
      if (0 == gid) {
        return null;
      }
      // get tileset
      var tileset:openfl.tiled.Tileset = this.mMap.tilesetByGid(gid);
      if (null == tileset) {
        return null;
      }
      // subtract first gid from tileset
      gid -= tileset.firstgid;
      // return tile by gid
      return tileset.getTileByGid(gid);
    }
    // handle infinite maps
    for (chunk in this.data.chunk) {
      // check if chunk is affected
      if (!(chunk.x * this.mMap.tilewidth <= x
        && chunk.x * this.mMap.tilewidth + this.mMap.tilewidth * chunk.width > x
        && chunk.y * this.mMap.tileheight <= y
        && chunk.y * this.mMap.tileheight + this.mMap.tileheight * chunk.height > y)) {
        continue;
      }
      var realX:Int = x - chunk.x * this.mMap.tilewidth;
      var realY:Int = y - chunk.y * this.mMap.tileheight;
      // get id
      var id:Int = Std.int(realY / this.mMap.tileheight) * chunk.width + Std.int(realX / this.mMap.tilewidth);
      // get gid
      var gid:Int = chunk.tile[id].gid;
      // handle invalid
      if (0 == gid) {
        return null;
      }
      // get tileset
      var tileset:openfl.tiled.Tileset = this.mMap.tilesetByGid(gid);
      if (null == tileset) {
        return null;
      }
      // subtract first gid from tileset
      gid -= tileset.firstgid;
      // return tile by gid
      return tileset.getTileByGid(gid);
    }
    // nothing found, return null
    return null;
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
    // array of tiles
    var tiles:Array<openfl.tiled.tileset.Tile> = new Array<openfl.tiled.tileset.Tile>();
    var tileId:Array<Int> = new Array<Int>();
    // loop through whole size
    var max:Int = width * height;
    for (i in 0...max) {
      // calculate tx and ty
      var tx:Int = Std.int(i % width);
      var ty:Int = Std.int(i / height);
      // get tile at x/y coordinate
      var tile:openfl.tiled.tileset.Tile = this.getTileAt(x + tx, y + ty);
      var id:Int = this.getTileGidAt(x + tx, y + ty);
      // push tile if not null and not yet existing
      if (tile != null && -1 == Lambda.indexOf(tiles, tile)) {
        tiles.push(tile);
      }
      // push tile id if set and not yet existing
      if (id != 0 && -1 == tileId.indexOf(id)) {
        tileId.push(id);
      }
    }
    // check for collision enabled on layer level
    if (this.properties?.propertyByName(Helper.COLLISION_PROPERTY_NAME) != null && tileId.length > 0) {
      return true;
    }
    // iterate tiles
    for (tile in tiles) {
      // handle possible collision by tile properties
      if (tile.properties?.propertyByName(Helper.COLLISION_PROPERTY_NAME)?.value == "true") {
        return true;
      }
    }
    // return no collision
    return false;
  }

  /**
   * Helper to evaluate width
   * @return Int
   */
  public function evaluateWidth():Int {
    if (0 == this.data.chunk.length) {
      return this.width;
    }
    var maxWidth:Int = 0;
    // loop through all layers
    for (chunk in this.data.chunk) {
      if (chunk.x + chunk.width > maxWidth) {
        // check for new max width
        maxWidth = chunk.x + chunk.width;
      }
    }
    return maxWidth;
  }

  /**
   * Helper to evaluate height
   * @return Int
   */
  public function evaluateHeight():Int {
    if (0 == this.data.chunk.length) {
      return this.height;
    }
    var maxHeight:Int = 0;
    // loop through all layers
    for (chunk in this.data.chunk) {
      if (chunk.y + chunk.height > maxHeight) {
        // check for new map height
        maxHeight = chunk.y + chunk.height;
      }
    }
    return maxHeight;
  }
}
