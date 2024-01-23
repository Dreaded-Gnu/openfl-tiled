package openfl.tiled;

import openfl.errors.Error;
import openfl.tiled.map.RenderOrder;
import openfl.display.Tile;
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
          this.properties = new openfl.tiled.Properties(child);
      }
    }
  }

  /**
   * Internal helper to render position
   * @param displayObject
   * @param offsetX
   * @param offsetY
   * @param x
   * @param y
   * @param tilemapData
   */
  private function renderLayer(
    displayObject:Sprite,
    offsetX:Int,
    offsetY:Int,
    x:Int,
    y:Int,
    tilemapData:std.Map<Int, openfl.display.Tilemap>
  ):Void {
    // calculate array position depending on x / y
    var id:Int = this.mMap.height * y + x;
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

    if (null == tilemapData.get(tileset.firstgid)) {
      var tm:openfl.display.Tilemap = new openfl.display.Tilemap(
        this.width * tileset.tilewidth,
        this.height * tileset.tileheight,
        tileset.tileset
      );
      tm.alpha = this.opacity;
      tm.visible = 1 == this.visible;
      tilemapData.set(tileset.firstgid, tm);
    }
    // generate tile
    var t:openfl.display.Tile = null;
    switch (this.mMap.orientation) {
      case MapOrientationIsometric,
           MapOrientationStaggered:
        t = new openfl.display.Tile(
          gid,
          (x - y) * (tileset.tilewidth / 2),
          (x + y) * (tileset.tileheight / 2)
        );
        if (this.mMap.orientation == MapOrientationStaggered) {
          // default x and y position
          t.x = x * tileset.tilewidth;
          t.y = y * tileset.tileheight;
          if (this.mMap.staggeraxis == MapStaggerAxisY) {
            t.y = Std.int(t.y / 2);
            if (this.mMap.staggerindex == MapStaggerIndexOdd) {
              t.x += Std.int(( y & 1 ) * tileset.tilewidth / 2);
            } else if (this.mMap.staggerindex == MapStaggerIndexEven) {
              t.x -= Std.int(( y & 1 ) * tileset.tilewidth / 2);
            }
          } else if (this.mMap.staggeraxis == MapStaggerAxisX) {
            t.x = Std.int(t.x / 2);
            if (this.mMap.staggerindex == MapStaggerIndexOdd) {
              t.y += Std.int(( x & 1 ) * tileset.tileheight / 2);
            } else if (this.mMap.staggerindex == MapStaggerIndexEven) {
              t.y -= Std.int(( x & 1 ) * tileset.tileheight / 2);
            }
          }
        }
        // apply position correction when tileheight is greater than tilemap
        if (tileset.tileheight > this.mMap.tileheight) {
          t.y = Std.int(t.y / (tileset.tileheight / this.mMap.tileheight));
        }
        if (tileset.tilewidth > this.mMap.tilewidth) {
          t.x = Std.int(t.x / (tileset.tilewidth / this.mMap.tilewidth));
        }
        // apply tileoffset
        t.x -= tileset.tileoffset.x;
        t.y -= tileset.tileoffset.y;
        // apply render offset
        t.x -= offsetX;
        t.y -= offsetY;
      case MapOrientationOrthogonal:
        t = new openfl.display.Tile(
          gid,
          x * this.mMap.tilewidth - tileset.tileoffset.x - offsetX,
          y * this.mMap.tileheight - tileset.tileoffset.y - offsetY
        );
      case MapOrientationHexagonal:
        t = new openfl.display.Tile(
          gid,
          x * this.mMap.tilewidth - tileset.tileoffset.x - offsetX,
          y * this.mMap.tileheight - tileset.tileoffset.y - offsetY
        );
        if (this.mMap.staggeraxis == MapStaggerAxisY) {
          var adjustX:Int = 0;
          if (this.mMap.staggerindex == MapStaggerIndexEven) {
            if (0 != (y + 1) % 2) {
              adjustX = this.mMap.hexsidelength;
            }
          } else if(this.mMap.staggerindex == MapStaggerIndexOdd) {
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
          } else if(this.mMap.staggerindex == MapStaggerIndexOdd) {
            if (0 == (y + 1) % 2) {
              adjustY = this.mMap.hexsidelength;
            }
          }
          t.y += adjustY;
          t.x -= (this.mMap.hexsidelength / 2) * x;
        }
    }
    // add tile at position
    tilemapData.get(tileset.firstgid).addTile(t);
  }

  /**
   * Helper to render chunk to tilemap
   * @param displayObject
   * @param offsetX
   * @param offsetY
   * @param chunk
   * @param tilemapData
   */
  private function renderChunk(
    displayObject:Sprite,
    offsetX:Int,
    offsetY:Int,
    chunk:openfl.tiled.layer.Chunk,
    tilemapData:std.Map<Int, openfl.display.Tilemap>
  ) {
    for (y in 0...chunk.height) {
      // skip row when it's not visible due to offsetY
      if (
        offsetY > (y + chunk.y) * this.mMap.tileheight
        && offsetY > (y + chunk.y) * this.mMap.tileheight + this.mMap.tileheight
      ) {
        continue;
      }
      for (x in 0...chunk.width) {
        // skip column when it's not visible due to offsetX
        if (
          offsetX > (x + chunk.x) * this.mMap.tilewidth
          && offsetX > (x + chunk.x) * this.mMap.tilewidth + this.mMap.tilewidth
        ) {
          continue;
        }
        // get id of chunk
        var id:Int = chunk.height * y + x;
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
        if (null == tilemapData.get(tileset.firstgid)) {
          var tm:openfl.display.Tilemap = new openfl.display.Tilemap(
            this.mMap.width * tileset.tilewidth,
            this.mMap.height * tileset.tileheight,
            tileset.tileset
          );
          tm.alpha = this.opacity;
          tm.visible = 1 == this.visible;
          tilemapData.set(tileset.firstgid, tm);
        }
        // generate tile
        var t:openfl.display.Tile = null;
        switch (this.mMap.orientation) {
          case MapOrientationIsometric,
               MapOrientationStaggered:
            t = new openfl.display.Tile(
              gid,
              (x - y) * (tileset.tilewidth / 2),
              (x + y) * (tileset.tileheight / 2)
            );
            if (this.mMap.orientation == MapOrientationStaggered) {
              // default x and y position
              t.x = x * tileset.tilewidth;
              t.y = y * tileset.tileheight;
              if (this.mMap.staggeraxis == MapStaggerAxisY) {
                t.y = Std.int(t.y / 2);
                if (this.mMap.staggerindex == MapStaggerIndexOdd) {
                  t.x += Std.int(( y & 1 ) * tileset.tilewidth / 2);
                } else if (this.mMap.staggerindex == MapStaggerIndexEven) {
                  t.x -= Std.int(( y & 1 ) * tileset.tilewidth / 2);
                }
              } else if (this.mMap.staggeraxis == MapStaggerAxisX) {
                t.x = Std.int(t.x / 2);
                if (this.mMap.staggerindex == MapStaggerIndexOdd) {
                  t.y += Std.int(( x & 1 ) * tileset.tileheight / 2);
                } else if (this.mMap.staggerindex == MapStaggerIndexEven) {
                  t.y -= Std.int(( x & 1 ) * tileset.tileheight / 2);
                }
              }
            }
            // apply position correction when tileheight is greater than tilemap
            if (tileset.tileheight > this.mMap.tileheight) {
              t.y = Std.int(t.y / (tileset.tileheight / this.mMap.tileheight));
            }
            if (tileset.tilewidth > this.mMap.tilewidth) {
              t.x = Std.int(t.x / (tileset.tilewidth / this.mMap.tilewidth));
            }
            // apply tileoffset
            t.x -= tileset.tileoffset.x;
            t.y -= tileset.tileoffset.y;
          case MapOrientationOrthogonal:
            t = new openfl.display.Tile(
              gid,
              x * this.mMap.tilewidth - tileset.tileoffset.x,
              y * this.mMap.tileheight - tileset.tileoffset.y
            );
          case MapOrientationHexagonal:
            t = new openfl.display.Tile(
              gid,
              x * this.mMap.tilewidth - tileset.tileoffset.x,
              y * this.mMap.tileheight - tileset.tileoffset.y
            );
            if (this.mMap.staggeraxis == MapStaggerAxisY) {
              var adjustX:Int = 0;
              if (this.mMap.staggerindex == MapStaggerIndexEven) {
                if (0 != (y + 1) % 2) {
                  adjustX = this.mMap.hexsidelength;
                }
              } else if(this.mMap.staggerindex == MapStaggerIndexOdd) {
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
              } else if(this.mMap.staggerindex == MapStaggerIndexOdd) {
                if (0 == (y + 1) % 2) {
                  adjustY = this.mMap.hexsidelength;
                }
              }
              t.y += adjustY;
              t.x -= (this.mMap.hexsidelength / 2) * x;
            }
        }
        // apply offset
        if (
          this.mMap.orientation == MapOrientationIsometric
          || this.mMap.orientation == MapOrientationStaggered
        ) {
          t.x += chunk.x * this.mMap.tilewidth - offsetX;
          t.y += chunk.y * this.mMap.tileheight / 2 - offsetY;
        } else {
          t.x += chunk.x * this.mMap.tilewidth - offsetX;
          t.y += chunk.y * this.mMap.tileheight - offsetY;
        }
        // add tile at position
        tilemapData.get(tileset.firstgid).addTile(t);
      }
    }
  }

  /**
   * Render layer
   * @param displayObject
   * @param x
   * @param y
   */
  public function render(displayObject:Sprite, offsetX:Int, offsetY:Int):Void {
    var tilemapData:std.Map<Int, openfl.display.Tilemap> =
      new std.Map<Int, openfl.display.Tilemap>();
    // render layers
    switch (this.mMap.renderorder) {
      case RenderOrder.MapRenderOrderRightDown:
        if (this.mMap.infinite == 1) {
          // render chunk by chunk
          for (chunk in this.data.chunk) {
            this.renderChunk(
              displayObject,
              offsetX,
              offsetY,
              chunk,
              tilemapData
            );
          }
        } else {
          for (y in 0...this.height) {
            for (x in 0...this.width) {
              this.renderLayer(
                displayObject,
                offsetX,
                offsetY,
                x,
                y,
                tilemapData
              );
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

    // add display objects
    for (tm in tilemapData) {
      displayObject.addChild(tm);
    }
  }
}
