package tiledfl;

import openfl.errors.Error;
import tiledfl.map.RenderOrder;

/**
 * Layer representation
 */
class Layer implements tiledfl.Updatable {
  /**
   * Id
   */
  public var id(default, null):Int;

  /**
   * Name
   */
  public var name(default, null):String;

  /**
   * Class
   */
  public var klass(default, null):String;

  /**
   * X position
   */
  public var x(default, null):Int;

  /**
   * Y position
   */
  public var y(default, null):Int;

  /**
   * Width
   */
  public var width(default, null):Int;

  /**
   * Height
   */
  public var height(default, null):Int;

  /**
   * Opacity
   */
  public var opacity(default, null):Float;

  /**
   * Visible flag
   */
  public var visible(default, null):Int;

  /**
   * Tint color
   */
  public var tintcolor(default, null):String;

  /**
   * Offset x
   */
  public var offsetx(default, null):Int;

  /**
   * Offset y
   */
  public var offsety(default, null):Int;

  /**
   * Parallax x
   */
  public var parallaxx(default, null):Int;

  /**
   * Parallax y
   */
  public var parallaxy(default, null):Int;

  /**
   * Layer properties
   */
  public var properties(default, null):tiledfl.Properties;

  /**
   * Embedded layer data
   */
  public var data(default, null):tiledfl.layer.Data;

  private var mTileCheckContainer:std.Map<Int, std.Map<Int, tiledfl.helper.AnimatedTile>>;
  private var mMap:tiledfl.Map;

  /**
   * Constructor
   * @param node xml representation to parse
   * @param map map this layer belongs to
   * @param layerId layer id
   */
  public function new(node:Xml, map:tiledfl.Map, layerId:Int) {
    this.mMap = map;
    this.mTileCheckContainer = new std.Map<Int, std.Map<Int, tiledfl.helper.AnimatedTile>>();
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
          this.data = new tiledfl.layer.Data(child);
        case "properties":
          this.properties = new tiledfl.Properties(child);
      }
    }
  }

  /**
   * Internal helper to render layer
   * @param x
   * @param y
   * @param offsetX
   * @param offsetY
   * @param index
   * @return Int
   */
  private function renderLayer(x:Int, y:Int, offsetX:Int, offsetY:Int, index:Int):Int {
    var id:Int = x + y * this.width;
    // get gid
    var gid:Int = this.data.tile[id].gid;
    // handle invalid
    if (0 == gid) {
      return 0;
    }
    // get tileset
    var tileset:tiledfl.Tileset = this.mMap.tilesetByGid(gid);
    if (null == tileset) {
      return 0;
    }
    // generate tile
    var t:tiledfl.helper.AnimatedTile = this.generateTile(x, y, id, gid, tileset, id);
    // cache tilemap locally
    var tilemap:openfl.display.Tilemap = this.mMap.tilemap;
    // adjust x and y of tile by offset
    t.x -= offsetX;
    t.y -= offsetY;
    t.realX -= offsetX;
    t.realY -= offsetY;
    // add tile at position
    if (!this.mTileCheckContainer.get(tileset.firstgid).exists(id)) {
      // set item
      this.mTileCheckContainer.get(tileset.firstgid).set(id, t);
    }
    // skip coordinate if not visible
    if (!this.mMap.willBeVisible(Std.int(t.realX), Std.int(t.realY), tileset.tilewidth, tileset.tileheight)) {
      // check if it's displayed
      if (tilemap.contains(t)) {
        // just remove it from map
        tilemap.removeTile(t);
      }
      // skip rest
      return 0;
    }
    // add tile to tilemap
    tilemap.addTileAt(t, index);
    // return one added tile
    return 1;
  }

  /**
   * Helper to render chunk to tilemap and return greatest global index
   * @param chunk
   * @param chunkIndex
   * @return Void
   */
  private function renderChunk(chunk:tiledfl.layer.Chunk, chunkIndex:Int, offsetX:Int, offsetY:Int, mapIndex:Int, index:Int):Int {
    // calculate max to iterate to
    var max:Int = chunk.width * chunk.height;
    var count:Int = 0;
    // cache tilemap locally
    var tilemap:openfl.display.Tilemap = this.mMap.tilemap;
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
      var tileset:tiledfl.Tileset = this.mMap.tilesetByGid(gid);
      if (null == tileset) {
        continue;
      }
      // generate tile
      var t:tiledfl.helper.AnimatedTile = this.generateTile(x, y, id, gid, tileset, mapIndex, chunk, chunkIndex);
      // apply offset
      t.x -= offsetX;
      t.y -= offsetY;
      t.realX -= offsetX;
      t.realY -= offsetY;
      // get tile container for checking
      var map:std.Map<Int, tiledfl.helper.AnimatedTile> = this.mTileCheckContainer.get(chunkIndex);
      // add tile at position
      if (!map.exists(mapIndex)) {
        // set item
        map.set(mapIndex++, t);
      } else {
        // increment index to fake set item
        mapIndex++;
      }
      // skip coordinate if not visible
      if (!this.mMap.willBeVisible(Std.int(t.realX), Std.int(t.realY), tileset.tilewidth, tileset.tileheight)) {
        // check if it's displayed
        if (tilemap.contains(t)) {
          // just remove it from map
          tilemap.removeTile(t);
        }
        // skip rest
        continue;
      }
      // add tile to tilemap
      tilemap.addTileAt(t, index++);
      // increment count added
      count++;
    }
    return count;
  }

  /**
   * Helper to generate a tile to add
   * @param x
   * @param y
   * @param id
   * @param gid
   * @param tileset
   * @param mapIndex
   * @param chunk
   * @param chunkIndex
   * @return tiledfl.helper.AnimatedTile
   */
  private function generateTile(x:Int, y:Int, id:Int, gid:Int, tileset:tiledfl.Tileset, mapIndex:Int, chunk:tiledfl.layer.Chunk = null,
      chunkIndex:Int = -1):tiledfl.helper.AnimatedTile {
    // subtract first gid from tileset
    gid -= tileset.firstgid;
    // adjust x / y for chunked maps
    if (chunk != null) {
      if (this.mMap.orientation == MapOrientationIsometric || this.mMap.orientation == MapOrientationStaggered) {
        //// FIXME: IS THIS RIGHT THAT WAY?
        x += chunk.x;
        y += chunk.y;
      } else {
        x += chunk.x;
        y += chunk.y;
      }
    }
    // generate check container if necessary
    if (null == this.mTileCheckContainer.get(chunkIndex != -1 ? chunkIndex : tileset.firstgid)) {
      if (chunkIndex != -1) {
        this.mTileCheckContainer.set(chunkIndex, new std.Map<Int, tiledfl.helper.AnimatedTile>());
      } else {
        this.mTileCheckContainer.set(tileset.firstgid, new std.Map<Int, tiledfl.helper.AnimatedTile>());
      }
    }
    var ts:openfl.display.Tileset = tileset.tileset;
    var tile:tiledfl.tileset.Tile = tileset.getTileByGid(gid);
    if (tile?.tileset != null) {
      ts = tile.tileset;
    }
    var layerTile:tiledfl.layer.Tile = chunk != null ? chunk.tile[id] : this.data.tile[id];
    // get tile container for checking
    var map:std.Map<Int, tiledfl.helper.AnimatedTile> = this.mTileCheckContainer.get(chunkIndex != -1 ? chunkIndex : tileset.firstgid);
    // generate tile
    var t:tiledfl.helper.AnimatedTile = null;
    switch (this.mMap.orientation) {
      case MapOrientationIsometric, MapOrientationStaggered:
        if (map.exists(mapIndex)) {
          t = map.get(mapIndex);
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
          // apply flipping
          tiledfl.Helper.applyTileFlipping(this.mMap, t, layerTile, tileset);
        } else {
          t = new tiledfl.helper.AnimatedTile(tile?.tileset != null ? 0 : gid, (x - y) * (tileset.tilewidth / 2), (x + y) * (tileset.tileheight / 2), 1,
            1, 0, tileset.tile[gid]?.animation, this.mMap);
          // set tileset
          t.tileset = ts;
          // apply flipping
          tiledfl.Helper.applyTileFlipping(this.mMap, t, layerTile, tileset);
        }
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
        if (map.exists(mapIndex)) {
          t = map.get(mapIndex);
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
          // apply flipping
          tiledfl.Helper.applyTileFlipping(this.mMap, t, layerTile, tileset);
        } else {
          t = new tiledfl.helper.AnimatedTile(tile?.tileset != null ? 0 : gid, x * this.mMap.tilewidth, y * this.mMap.tileheight, 1, 1, 0,
            tileset.tile[gid]?.animation, this.mMap);
          // set tileset
          t.tileset = ts;
          // apply flipping
          tiledfl.Helper.applyTileFlipping(this.mMap, t, layerTile, tileset);
        }
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
        if (map.exists(mapIndex)) {
          t = map.get(mapIndex);
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
          // apply flipping
          tiledfl.Helper.applyTileFlipping(this.mMap, t, layerTile, tileset);
        } else {
          t = new tiledfl.helper.AnimatedTile(tile?.tileset != null ? 0 : gid, x * this.mMap.tilewidth, y * this.mMap.tileheight, 1, 1, 0,
            tileset.tile[gid]?.animation, this.mMap);
          // set tileset
          t.tileset = ts;
          // apply flipping
          tiledfl.Helper.applyTileFlipping(this.mMap, t, layerTile, tileset);
        }
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
   * @param offsetX
   * @param offsetY
   * @param index
   * @return Int
   */
  @:dox(hide) @:noCompletion public function update(offsetX:Int, offsetY:Int, index:Int):Int {
    switch (this.mMap.renderorder) {
      case RenderOrder.MapRenderOrderRightDown:
        if (this.mMap.infinite == 1) {
          var chunkIdx:Int = 0;
          var total:Int = 0;
          var mapIdx:Int = 0;
          // render chunk by chunk
          for (chunk in this.data.chunk) {
            total += this.renderChunk(chunk, chunkIdx, offsetX, offsetY, mapIdx, index + total);
            chunkIdx++;
            mapIdx += chunk.width * chunk.height;
          }
          return total;
        } else {
          var max:Int = this.width * this.height;
          var total:Int = 0;
          for (i in 0...max) {
            // calculate x and y
            var x:Int = Std.int(i % this.width);
            var y:Int = Std.int(i / this.width);
            // call render layer
            total += this.renderLayer(x, y, offsetX, offsetY, index + total);
          }
          return total;
        }
      case RenderOrder.MapRenderOrderRightUp:
        throw new Error('Unsupported render order right-up');
      case RenderOrder.MapRenderOrderLeftDown:
        throw new Error('Unsupported render order left-down');
      case RenderOrder.MapRenderOrderLeftUp:
        throw new Error('Unsupported render order left-up');
    }
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
      var tileset:tiledfl.Tileset = this.mMap.tilesetByGid(gid);
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
      var tileset:tiledfl.Tileset = this.mMap.tilesetByGid(gid);
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
   * @return tiledfl.tileset.Tile
   */
  private function getTileAt(x:Int, y:Int):tiledfl.tileset.Tile {
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
      var tileset:tiledfl.Tileset = this.mMap.tilesetByGid(gid);
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
      var tileset:tiledfl.Tileset = this.mMap.tilesetByGid(gid);
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
  @:dox(hide) @:noCompletion public function collides(x:Int, y:Int, width:Int, height:Int):Bool {
    // array of tiles
    var tiles:Array<tiledfl.tileset.Tile> = new Array<tiledfl.tileset.Tile>();
    var tileId:Array<Int> = new Array<Int>();
    // apply rendering offset for collision check
    x += this.mMap.renderOffsetX;
    y += this.mMap.renderOffsetY;
    // loop through whole size
    var max:Int = width * height;
    for (i in 0...max) {
      // calculate tx and ty
      var tx:Int = Std.int(i % width);
      var ty:Int = Std.int(i / height);
      // get tile at x/y coordinate
      var tile:tiledfl.tileset.Tile = this.getTileAt(x + tx, y + ty);
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
  @:dox(hide) @:noCompletion public function evaluateWidth():Int {
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
  @:dox(hide) @:noCompletion public function evaluateHeight():Int {
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
