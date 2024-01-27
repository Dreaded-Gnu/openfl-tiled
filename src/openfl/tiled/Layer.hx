package openfl.tiled;

import openfl.geom.Matrix;
import openfl.errors.Error;
import openfl.tiled.map.RenderOrder;
import openfl.display.Tile;
import openfl.display.Sprite;

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
    // subtract first gid from tileset
    gid -= tileset.firstgid;
    if (null == this.mTilemapData.get(tileset.firstgid)) {
      var tc:openfl.display.TileContainer = new openfl.display.TileContainer(this.x * tileset.tilewidth, this.y * tileset.tileheight,);
      tc.alpha = this.opacity;
      tc.visible = 1 == this.visible;
      this.mTilemapData.set(tileset.firstgid, tc);
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
        if (mTilemapData.get(tileset.firstgid).getTileAt(id) != null) {
          t = cast(mTilemapData.get(tileset.firstgid).getTileAt(id), openfl.tiled.helper.AnimatedTile);
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
          t.tileset = ts;
          t.map = this.mMap;
        } else {
          t = new openfl.tiled.helper.AnimatedTile(tile?.tileset != null ? 0 : gid, (x - y) * (tileset.tilewidth / 2), (x + y) * (tileset.tileheight / 2), 1,
            1, 0, tileset.tile[gid]?.animation, this.mMap);
          t.tileset = ts;
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
          t.x += this.mMap.width / 2 * tileset.tilewidth - tileset.tileoffset.x;
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
        if (mTilemapData.get(tileset.firstgid).getTileAt(id) != null) {
          t = cast(mTilemapData.get(tileset.firstgid).getTileAt(id), openfl.tiled.helper.AnimatedTile);
          // gid
          t.id = tile?.tileset != null ? 0 : gid;
          // x / y position
          t.x = x * this.mMap.tilewidth - tileset.tileoffset.x;
          t.y = y * this.mMap.tileheight - tileset.tileoffset.y;
          // scaling depending on object size
          t.scaleX = 1;
          t.scaleY = 1;
          t.rotation = 0;
          t.animation = tileset.tile[gid]?.animation;
          t.tileset = ts;
          t.map = this.mMap;
        } else {
          t = new openfl.tiled.helper.AnimatedTile(tile?.tileset != null ? 0 : gid, x * this.mMap.tilewidth - tileset.tileoffset.x,
            y * this.mMap.tileheight - tileset.tileoffset.y, 1, 1, 0, tileset.tile[gid]?.animation, this.mMap);
          t.tileset = ts;
        }
      case MapOrientationHexagonal:
        if (mTilemapData.get(tileset.firstgid).getTileAt(id) != null) {
          t = cast(mTilemapData.get(tileset.firstgid).getTileAt(id), openfl.tiled.helper.AnimatedTile);
          // gid
          t.id = tile?.tileset != null ? 0 : gid;
          // x / y position
          t.x = x * this.mMap.tilewidth - tileset.tileoffset.x;
          t.y = y * this.mMap.tileheight - tileset.tileoffset.y;
          // scaling depending on object size
          t.scaleX = 1;
          t.scaleY = 1;
          t.rotation = 0;
          t.animation = tileset.tile[gid]?.animation;
          t.tileset = ts;
          t.map = this.mMap;
        } else {
          t = new openfl.tiled.helper.AnimatedTile(tile?.tileset != null ? 0 : gid, x * this.mMap.tilewidth - tileset.tileoffset.x,
            y * this.mMap.tileheight - tileset.tileoffset.y, 1, 1, 0, tileset.tile[gid]?.animation, this.mMap);
          t.tileset = ts;
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
        }
    }
    // add tile at position
    if (this.mTilemapData.get(tileset.firstgid).getTileAt(id) == null) {
      this.mTilemapData.get(tileset.firstgid).addTileAt(t, id);
    }
  }

  /**
   * Helper to render chunk to tilemap and return greatest global index
   * @param chunk
   * @param chunkIndex
   * @return Void
   */
  private function renderChunk(chunk:openfl.tiled.layer.Chunk, chunkIndex:Int):Void {
    for (y in 0...chunk.height) {
      for (x in 0...chunk.width) {
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
        // subtract firstgid
        gid -= tileset.firstgid;
        // create tilemap if necessary
        if (null == this.mTilemapData.get(chunkIndex)) {
          var tc:openfl.display.TileContainer = null;
          if (this.mMap.orientation == MapOrientationIsometric || this.mMap.orientation == MapOrientationStaggered) {
            tc = new openfl.display.TileContainer((x + chunk.x) * this.mMap.tilewidth, (y + chunk.y) * this.mMap.tileheight / 2,);
          } else {
            tc = new openfl.display.TileContainer((x + chunk.x) * tileset.tilewidth, (y + chunk.y) * tileset.tileheight,);
          }
          tc.alpha = this.opacity;
          tc.visible = 1 == this.visible;
          this.mTilemapData.set(chunkIndex, tc);
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
            if (mTilemapData.get(chunkIndex).getTileAt(id) != null) {
              t = cast(mTilemapData.get(chunkIndex).getTileAt(id), openfl.tiled.helper.AnimatedTile);
              // gid
              t.id = gid;
              // x / y position
              t.x = (x - y) * (tileset.tilewidth / 2);
              t.y = (x + y) * (tileset.tileheight / 2);
              // scaling depending on object size
              t.scaleX = 1;
              t.scaleY = 1;
              t.rotation = 0;
              t.animation = tileset.tile[gid]?.animation;
              t.tileset = ts;
              t.map = this.mMap;
            } else {
              t = new openfl.tiled.helper.AnimatedTile(gid, (x - y) * (tileset.tilewidth / 2), (x + y) * (tileset.tileheight / 2), 1, 1, 0,
                tileset.tile[gid]?.animation, this.mMap);
              t.tileset = ts;
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
              t.x += this.mMap.width / 2 * tileset.tilewidth - tileset.tileoffset.x;
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
            if (mTilemapData.get(chunkIndex).getTileAt(id) != null) {
              t = cast(mTilemapData.get(chunkIndex).getTileAt(id), openfl.tiled.helper.AnimatedTile);
              t.id = gid;
              // x / y position
              t.x = x * this.mMap.tilewidth - tileset.tileoffset.x;
              t.y = y * this.mMap.tileheight - tileset.tileoffset.y;
              // scaling depending on object size
              t.scaleX = 1;
              t.scaleY = 1;
              t.rotation = 0;
              t.animation = tileset.tile[gid]?.animation;
              t.tileset = ts;
              t.map = this.mMap;
            } else {
              t = new openfl.tiled.helper.AnimatedTile(gid, x * this.mMap.tilewidth - tileset.tileoffset.x, y * this.mMap.tileheight - tileset.tileoffset.y,
                1, 1, 0, tileset.tile[gid]?.animation, this.mMap);
              t.tileset = ts;
            }
          case MapOrientationHexagonal:
            if (mTilemapData.get(chunkIndex).getTileAt(id) != null) {
              t = cast(mTilemapData.get(chunkIndex).getTileAt(id), openfl.tiled.helper.AnimatedTile);
              // gid
              t.id = gid;
              // x / y position
              t.x = x * this.mMap.tilewidth - tileset.tileoffset.x;
              t.y = y * this.mMap.tileheight - tileset.tileoffset.y;
              // scaling depending on object size
              t.scaleX = 1;
              t.scaleY = 1;
              t.rotation = 0;
              t.animation = tileset.tile[gid]?.animation;
              t.tileset = ts;
              t.map = this.mMap;
            } else {
              t = new openfl.tiled.helper.AnimatedTile(gid, x * this.mMap.tilewidth - tileset.tileoffset.x, y * this.mMap.tileheight - tileset.tileoffset.y,
                1, 1, 0, tileset.tile[gid]?.animation, this.mMap);
              t.tileset = ts;
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
            }
        }
        // add tile at position
        if (this.mTilemapData.get(chunkIndex).getTileAt(id) == null) {
          this.mTilemapData.get(chunkIndex).addTileAt(t, id);
        }
      }
    }
  }

  /**
   * Render a layer to tilemap
   * @param tilemap
   * @param offsetX
   * @param offsetY
   * @param previousOffsetX
   * @param previousOffsetY
   */
  public function update(tilemap:openfl.display.Tilemap, offsetX:Int, offsetY:Int, previousOffsetX:Int, previousOffsetY:Int):Void {
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
          for (y in 0...this.height) {
            for (x in 0...this.width) {
              this.renderLayer(x, y);
            }
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
   * @param sprite
   */
  public function collides(sprite:openfl.display.Sprite):Bool {
    // check for collide property is set for layer and is set to true
      // check for any collision where gid is valid at current position
    // get tile at position
      // check for collide property exists for tile and is set to true
      // check collision against tile and possible surrounding tiles
    return false;
  }
}
