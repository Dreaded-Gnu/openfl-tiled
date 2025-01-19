package openfl.tiled;

import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * Tiled object
 */
class Object implements openfl.tiled.helper.Flippable implements openfl.tiled.Updatable {
  /**
   * ID
   */
  public var id(default, null):Int;

  /**
   * Name
   */
  public var name(default, null):String;

  /**
   * Type
   */
  public var type(default, null):String;

  /**
   * X position
   */
  public var x(default, null):Float;

  /**
   * Y position
   */
  public var y(default, null):Float;

  /**
   * Width
   */
  public var width(default, null):Float;

  /**
   * Height
   */
  public var height(default, null):Float;

  /**
   * Rotation
   */
  public var rotation(default, null):Float;

  /**
   * Gid
   */
  public var gid(get, null):Int;

  /**
   * Visible flag
   */
  public var visible(default, null):Int;

  /**
   * Template
   */
  public var template(default, null):String;

  /**
   * Object properties
   */
  public var properties(default, null):openfl.tiled.Properties;

  /**
   * Ellipse instance
   */
  public var ellipse(default, null):openfl.tiled.object.Ellipse;

  /**
   * Point instance
   */
  public var point(default, null):openfl.tiled.object.Point;

  /**
   * Polygon instance
   */
  public var polygon(default, null):openfl.tiled.object.Polygon;

  /**
   * Polyline instance
   */
  public var polyline(default, null):openfl.tiled.object.Polyline;

  /**
   * Text instance
   */
  public var text(default, null):openfl.tiled.object.Text;

  private var mTile:openfl.tiled.helper.AnimatedTile;
  private var mMap:openfl.tiled.Map;
  private var mGid:Int;
  #if openfl_tiled_debug_render_objects
  private var mShape:openfl.display.Shape;
  private var mTileset:openfl.display.Tileset;
  #end

  /**
   * Constructor
   * @param node xml representation to parse
   * @param map map this object belongs to
   */
  public function new(node:Xml, map:openfl.tiled.Map) {
    this.mMap = map;
    #if openfl_tiled_debug_render_objects
    this.mShape = new openfl.display.Shape();
    #end
    // parse properties
    this.id = node.exists("id") ? Std.parseInt(node.get("id")) : 0;
    this.name = node.exists("name") ? node.get("name") : "";
    this.type = node.exists("type") ? node.get("type") : "";
    this.x = node.exists("x") ? Std.parseFloat(node.get("x")) : 0;
    this.y = node.exists("y") ? Std.parseFloat(node.get("y")) : 0;
    this.width = node.exists("width") ? Std.parseFloat(node.get("width")) : 0;
    this.height = node.exists("height") ? Std.parseFloat(node.get("height")) : 0;
    this.rotation = node.exists("rotation") ? Std.parseInt(node.get("rotation")) : 0;
    this.mGid = node.exists("gid") ? Std.parseInt(node.get("gid")) : 0;
    this.visible = node.exists("visible") ? Std.parseInt(node.get("visible")) : 1;
    this.template = node.get("template");
    // loop through childs
    for (child in node) {
      if (child.nodeType != Xml.Element) {
        // skip non elements
        continue;
      }
      switch (child.nodeName) {
        case "properties":
          this.properties = new openfl.tiled.Properties(child);
        case "ellipse":
          this.ellipse = new openfl.tiled.object.Ellipse(child, this);
        case "point":
          this.point = new openfl.tiled.object.Point(child, this);
        case "polygon":
          this.polygon = new openfl.tiled.object.Polygon(child, this);
        case "polyline":
          this.polyline = new openfl.tiled.object.Polyline(child, this);
        case "text":
          this.text = new openfl.tiled.object.Text(child, this);
      }
    }
  }

  /**
   * Getter for gid property
   * @return Int
   */
  private function get_gid():Int {
    return Helper.extractGid(this.mGid);
  }

  /**
   * Helper for flipped horizontally checks
   * @return True if flipped horizontally, else false
   */
  public function isFlippedHorizontally():Bool {
    return Helper.isGidFlippedHorizontally(this.mGid);
  }

  /**
   * Helper for flipped vertically checks
   * @return True if flipped vertically, else false
   */
  public function isFlippedVertically():Bool {
    return Helper.isGidFlippedVertically(this.mGid);
  }

  /**
   * Helper for flipped diagonally checks
   * @return True if flipped diagonally, else false
   */
  public function isFlippedDiagonally():Bool {
    return Helper.isGidFlippedDiagonally(this.mGid);
  }

  /**
   * Helper for flipped hexagonal 120 checks
   * @return True if rotated hexagonal by 120, else false
   */
  public function isRotatedHexagonal120():Bool {
    return Helper.isGidRotatedHexagonal120(this.mGid);
  }

  /**
   * Helper to render object
   * @param offsetX
   * @param offsetY
   * @param tileIndex
   * @return Int
   */
  private function renderTileObject(offsetX:Int, offsetY:Int, tileIndex:Int):Int {
    var gid:Int = this.gid;
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
    // get tileset and tile
    var ts:openfl.display.Tileset = tileset.tileset;
    var tile:openfl.tiled.tileset.Tile = tileset.getTileByGid(gid);
    if (tile?.tileset != null) {
      ts = tile.tileset;
    }
    // generate tile
    var t:openfl.tiled.helper.AnimatedTile = null;
    // handle already set
    if (this.mTile != null) {
      t = this.mTile;
      // gid
      t.id = tile?.tileset != null ? 0 : gid;
      // x / y position
      t.x = this.x - tileset.tileoffset.x;
      t.y = this.y - tileset.tileoffset.y - this.height;
      // scaling depending on object size
      t.scaleX = this.width / (tile?.tileset != null ? tile.width : tileset.tilewidth);
      t.scaleY = this.height / (tile?.tileset != null ? tile.height : tileset.tileheight);
      t.rotation = 0;
      t.animation = tileset.tile[gid]?.animation;
      t.tileset = ts;
      t.map = this.mMap;
      // apply flipping
      openfl.tiled.Helper.applyTileFlipping(this.mMap, t, this, tileset);
    } else {
      t = new openfl.tiled.helper.AnimatedTile( // gid
        tile?.tileset != null ? 0 : gid, // x / y position
        this.x - tileset.tileoffset.x,
        this.y - tileset.tileoffset.y - this.height, // scaling depending on object size
        this.width / (tile?.tileset != null ? tile.width : tileset.tilewidth),
        this.height / (tile?.tileset != null ? tile.height : tileset.tileheight), 0, tileset.tile[gid]?.animation, this.mMap);
      // set tileset
      t.tileset = ts;
      // apply flipping
      openfl.tiled.Helper.applyTileFlipping(this.mMap, t, this, tileset);
    }
    // cache tilemap locally
    var tilemap:openfl.display.Tilemap = this.mMap.tilemap;
    // adjust x and y of tile
    t.x -= offsetX;
    t.y -= offsetY;
    t.realX -= offsetX;
    t.realY -= offsetY;
    // cahce tile if not cached
    if (this.mTile == null) {
      this.mTile = t;
    }
    // skip coordinate if not visible
    if (!this.mMap.willBeVisible(Std.int(t.realX), Std.int(t.realY), Std.int(this.width * t.scaleX), Std.int(this.height * t.scaleY))) {
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

  #if openfl_tiled_debug_render_objects
  /**
   * Wrapper to transform generated shape into tile with tileset
   */
  private function transformShapToTile(shapeOffsetX:Float, shapeOffsetY:Float):Void {
    // draw shape to bitmap data
    var bmd:openfl.display.BitmapData = new openfl.display.BitmapData(Std.int(this.mShape.width), Std.int(this.mShape.height), true, 0);
    bmd.draw(this.mShape);
    // parse bitmapdata to tileset
    var rect:Array<Rectangle> = new Array<Rectangle>();
    rect.push(new Rectangle(this.mShape.x, this.mShape.y, bmd.width, bmd.height));
    this.mTileset = new openfl.display.Tileset(bmd, rect);
    // build tile if not built
    if (this.mTile == null) {
      this.mTile = new openfl.tiled.helper.AnimatedTile(0, this.x, this.y, 1, 1, 0, null, this.mMap);
    }
    // set x and y
    this.mTile.x = this.x - shapeOffsetX;
    this.mTile.y = this.y - shapeOffsetY;
    // set tileset
    this.mTile.tileset = this.mTileset;
  }

  /**
   * Simple debugging function to render an object
   */
  private function renderObject(offsetX:Int, offsetY:Int, tileIndex:Int):Int {
    // cache tilemap
    var tilemap:openfl.display.Tilemap = this.mMap.tilemap;
    // clear shape
    this.mShape.graphics.clear();
    // set line stile
    this.mShape.graphics.lineStyle(1, this.mMap.debugRenderObjectColor, 1);
    // prepare shape offset x and y
    var shapeOffsetX:Float = 0;
    var shapeOffsetY:Float = 0;
    // handle object types
    if (this.polyline != null) {
      // determine offset for rendering
      for (point in this.polyline.points) {
        shapeOffsetX = Math.min(shapeOffsetX, point.x);
        shapeOffsetY = Math.min(shapeOffsetY, point.y);
      }
      // transform to absolute
      shapeOffsetX = Math.abs(shapeOffsetX);
      shapeOffsetY = Math.abs(shapeOffsetY);
      // polyline rendering rendering line from point to point
      for (idx in 0...this.polyline.points.length - 1) {
        // get line point 1 and 2
        var linePoint1:Point = new Point(this.polyline.points[idx].x + shapeOffsetX, this.polyline.points[idx].y + shapeOffsetY);
        var linePoint2:Point = new Point(this.polyline.points[idx + 1].x + shapeOffsetX, this.polyline.points[idx + 1].y + shapeOffsetY);
        // move to point one
        this.mShape.graphics.moveTo(linePoint1.x, linePoint1.y);
        // draw line to point 2
        this.mShape.graphics.lineTo(linePoint2.x, linePoint2.y);
      }
    } else if (this.polygon != null) {
      // determine offset for rendering
      for (point in this.polyline.points) {
        shapeOffsetX = Math.min(shapeOffsetX, point.x);
        shapeOffsetY = Math.min(shapeOffsetY, point.y);
      }
      // transform to absolute
      shapeOffsetX = Math.abs(shapeOffsetX);
      shapeOffsetY = Math.abs(shapeOffsetY);
      // polygon rendering rendering line from point to point
      for (idx in 0...this.polygon.points.length - 1) {
        // get line point 1 and 2
        var linePoint1:Point = new Point(this.polygon.points[idx].x + shapeOffsetX, this.polygon.points[idx].y + shapeOffsetY);
        var linePoint2:Point = new Point(this.polygon.points[idx + 1].x + shapeOffsetX, this.polygon.points[idx + 1].y + shapeOffsetY);
        // move to point one
        this.mShape.graphics.moveTo(linePoint1.x, linePoint1.y);
        // draw line to point 2
        this.mShape.graphics.lineTo(linePoint2.x, linePoint2.y);
      }
    } else if (this.ellipse != null) {
      // generate shape
      this.mShape.graphics.drawEllipse(0, 0, this.width, this.height);
    } else if (this.point != null) {
      // generate shape
      this.mShape.graphics.drawRect(0, 0, 1, 1);
    } else {
      // generate shape
      this.mShape.graphics.drawRect(0, 0, this.width, this.height);
    }
    // transform shape to tile
    this.transformShapToTile(shapeOffsetX, shapeOffsetY);
    // apply offset x and y
    this.mTile.x -= offsetX;
    this.mTile.y -= offsetY;
    this.mTile.realX -= offsetX;
    this.mTile.realY -= offsetY;
    // skip coordinate if not visible
    if (!this.mMap.willBeVisible(Std.int(this.mTile.realX), Std.int(this.mTile.realY), this.mTileset.bitmapData.width, this.mTileset.bitmapData.height)) {
      // check if it's displayed
      if (tilemap.contains(this.mTile)) {
        // just remove it from map
        tilemap.removeTile(this.mTile);
      }
      // skip rest
      return 0;
    }
    // add tile to tilemap
    tilemap.addTileAt(this.mTile, tileIndex);
    // return one object added
    return 1;
  }
  #end

  /**
   * Checks for collision
   * @param x
   * @param y
   * @param width
   * @param height
   * @return Bool
   */
  @:dox(hide) @:noCompletion public function collides(x:Int, y:Int, width:Int, height:Int):Bool {
    // cache tilemap locally
    var tilemap:openfl.display.Tilemap = this.mMap.tilemap;
    // float buffer
    var buffer:Float = .1;
    // loop through width and height
    for (tx in 0...width) {
      for (ty in 0...height) {
        if (this.polyline != null) {
          // poly line collision check by checking each line
          for (idx in 0...this.polyline.points.length - 1) {
            // get line point 1 and translate it into global
            var linePoint1:Point = new Point(this.x + this.polyline.points[idx].x, this.y + this.polyline.points[idx].y);
            linePoint1.copyFrom(tilemap.localToGlobal(linePoint1));
            // get line point 2 and translate it into global
            var linePoint2:Point = new Point(this.x + this.polyline.points[idx + 1].x, this.y + this.polyline.points[idx + 1].y);
            linePoint2.copyFrom(tilemap.localToGlobal(linePoint2));
            // create checkpoint and translate it into global
            var checkPoint:Point = new Point(x + tx + this.mMap.renderOffsetX, y + ty + this.mMap.renderOffsetY);
            checkPoint.copyFrom(tilemap.localToGlobal(checkPoint));
            // get distances
            var dist1:Float = Point.distance(checkPoint, linePoint1);
            var dist2:Float = Point.distance(checkPoint, linePoint2);
            // get line length
            var linelength:Float = Point.distance(linePoint1, linePoint2);
            // handle collision
            if (dist1 + dist2 >= linelength - buffer && dist1 + dist2 <= linelength + buffer) {
              return true;
            }
          }
        } else if (this.polygon != null) {
          // polygon collision check by checking each line
          for (idx in 0...this.polygon.points.length - 1) {
            // get line point 1 and translate it into global
            var linePoint1:Point = new Point(this.x + this.polygon.points[idx].x, this.y + this.polygon.points[idx].y);
            linePoint1.copyFrom(tilemap.localToGlobal(linePoint1));
            // get line point 2 and translate it into global
            var linePoint2:Point = new Point(this.x + this.polygon.points[idx + 1].x, this.y + this.polygon.points[idx + 1].y);
            linePoint2.copyFrom(tilemap.localToGlobal(linePoint2));
            // create checkpoint and translate it into global
            var checkPoint:Point = new Point(x + tx + this.mMap.renderOffsetX, y + ty + this.mMap.renderOffsetY);
            checkPoint.copyFrom(tilemap.localToGlobal(checkPoint));
            // get distances
            var dist1:Float = Point.distance(checkPoint, linePoint1);
            var dist2:Float = Point.distance(checkPoint, linePoint2);
            // get line length
            var linelength:Float = Point.distance(linePoint1, linePoint2);
            // handle collision
            if (dist1 + dist2 >= linelength - buffer && dist1 + dist2 <= linelength + buffer) {
              return true;
            }
          }
        } else if (this.ellipse != null) {
          // create checkpoint and translate it into global
          var checkPoint:Point = new Point(x + tx + this.mMap.renderOffsetX, y + ty + this.mMap.renderOffsetY);
          checkPoint.copyFrom(tilemap.localToGlobal(checkPoint));
          // get min point and translate into global
          var minPoint:Point = new Point(this.x, this.y);
          minPoint.copyFrom(tilemap.localToGlobal(minPoint));
          // get max point and translate into global
          var maxPoint:Point = new Point(this.x + this.width, this.y + this.height);
          maxPoint.copyFrom(tilemap.localToGlobal(maxPoint));
          // calculate width and height
          var width:Float = maxPoint.x - minPoint.x;
          var height:Float = maxPoint.y - minPoint.y;
          // calculate collision
          if (Math.pow(checkPoint.x - minPoint.x, 2) / Math.pow(width / 2, 2) + Math.pow(checkPoint.y - minPoint.y, 2) / Math.pow(height / 2, 2) <= 1) {
            return true;
          }
        } else if (this.point != null) {
          // create checkpoint and translate it into global
          var checkPoint:Point = new Point(x + tx + this.mMap.renderOffsetX, y + ty + this.mMap.renderOffsetY);
          checkPoint.copyFrom(tilemap.localToGlobal(checkPoint));
          // create point and translate into global
          var point:Point = new Point(this.x, this.y);
          point.copyFrom(tilemap.localToGlobal(point));
          // point collision check
          if (point.equals(checkPoint)) {
            return true;
          }
        } else {
          // create checkpoint and translate it into global
          var checkPoint:Point = new Point(x + tx + this.mMap.renderOffsetX, y + ty + this.mMap.renderOffsetY);
          checkPoint.copyFrom(tilemap.localToGlobal(checkPoint));
          // create min point and translate into global
          var minPoint:Point = new Point(this.x, this.y);
          minPoint.copyFrom(tilemap.localToGlobal(minPoint));
          // create max point and translate into global
          var maxPoint:Point = new Point(this.x + this.width, this.y + this.height);
          maxPoint.copyFrom(tilemap.localToGlobal(maxPoint));
          // create rectangle
          var rect:Rectangle = new Rectangle(minPoint.x, minPoint.y, maxPoint.x - minPoint.x, maxPoint.y - minPoint.y);
          // check if point contains rectangle
          if (rect.containsPoint(checkPoint)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /**
   * Update method
   * @param offsetX
   * @param offsetY
   * @param index
   */
  @:dox(hide) @:noCompletion public function update(offsetX:Int, offsetY:Int, index:Int):Int {
    var added:Int = 0;
    // render collision object if set
    #if openfl_tiled_debug_render_objects
    if (this.gid == 0) {
      added += this.renderObject(offsetX, offsetY, index);
    }
    #end
    // render tile object if set
    return this.renderTileObject(offsetX, offsetY, index + added) + added;
  }

  /**
   * Helper to evaluate width
   * @return Int
   */
  @:dox(hide) @:noCompletion public function evaluateWidth():Int {
    return 0;
  }

  /**
   * Helper to evaluate height
   * @return Int
   */
  @:dox(hide) @:noCompletion public function evaluateHeight():Int {
    return 0;
  }
}
