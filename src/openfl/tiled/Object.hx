package openfl.tiled;

import openfl.geom.Point;

class Object implements openfl.tiled.helper.Flippable {
  public var id(default, null):Int;
  public var name(default, null):String;
  public var type(default, null):String;
  public var x(default, null):Float;
  public var y(default, null):Float;
  public var width(default, null):Float;
  public var height(default, null):Float;
  public var rotation(default, null):Float;
  public var gid(get, null):Int;
  public var visible(default, null):Int;
  public var template(default, null):String;
  public var properties(default, null):openfl.tiled.Properties;
  public var ellipse(default, null):openfl.tiled.object.Ellipse;
  public var point(default, null):openfl.tiled.object.Point;
  public var polygon(default, null):openfl.tiled.object.Polygon;
  public var polyline(default, null):openfl.tiled.object.Polyline;
  public var text(default, null):openfl.tiled.object.Text;

  private var mMap:openfl.tiled.Map;
  private var mGid:Int;
  private var mShape:openfl.display.Shape;

  /**
   * Constructor
   * @param node
   * @param map
   */
  public function new(node:Xml, map:openfl.tiled.Map) {
    this.mMap = map;
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
   * Getter for flipped horizontally
   * @return Bool
   */
  public function isFlippedHorizontally():Bool {
    return Helper.isGidFlippedHorizontally(this.mGid);
  }

  /**
   * Getter for flipped vertically
   * @return Bool
   */
  public function isFlippedVertically():Bool {
    return Helper.isGidFlippedVertically(this.mGid);
  }

  /**
   * Getter for flipped diagonally
   * @return Bool
   */
  public function isFlippedDiagonally():Bool {
    return Helper.isGidFlippedDiagonally(this.mGid);
  }

  /**
   * Getter for flipped hexagonal 120
   * @return Bool
   */
  public function isRotatedHexagonal120():Bool {
    return Helper.isGidRotatedHexagonal120(this.mGid);
  }

  /**
   * Simple debugging function to render an object
   */
  private function render():Void {
    var tilemap:openfl.display.Tilemap = this.mMap.tilemap;
    if (this.mShape != null) {
      this.mShape.graphics.clear();
    } else {
      // generate shape
      this.mShape = new openfl.display.Shape();
    }
    if (this.polyline != null) {
      // poly line collision check by checking each line
      for (idx in 0...this.polyline.points.length - 1) {
        // get line point 1 and translate it into global
        var linePoint1:Point = new Point(this.x + this.polyline.points[idx].x, this.y + this.polyline.points[idx].y);
        linePoint1.copyFrom(tilemap.localToGlobal(linePoint1));
        // get line point 2 and translate it into global
        var linePoint2:Point = new Point(this.x + this.polyline.points[idx + 1].x, this.y + this.polyline.points[idx + 1].y);
        linePoint2.copyFrom(tilemap.localToGlobal(linePoint2));
        this.mShape.graphics.lineStyle(2, 0xff0000, 1);
        this.mShape.graphics.moveTo(linePoint1.x - this.mMap.renderOffsetX, linePoint1.y - this.mMap.renderOffsetY);
        this.mShape.graphics.lineTo(linePoint2.x - this.mMap.renderOffsetX, linePoint2.y - this.mMap.renderOffsetY);
      }
      Lib.current.stage.addChild(this.mShape);
    } else if (this.polygon != null) {
      /// FIXME: ADD LOGIC
    } else if (this.ellipse != null) {
      // create min point and translate into global
      var minPoint:Point = new Point(this.x, this.y);
      minPoint.copyFrom(tilemap.localToGlobal(minPoint));
      // create max point and translate into global
      var maxPoint:Point = new Point(this.x + this.width, this.y + this.height);
      maxPoint.copyFrom(tilemap.localToGlobal(maxPoint));
      // generate shape
      this.mShape.graphics.drawEllipse(this.mMap.renderOffsetX + minPoint.x, this.mMap.renderOffsetY + minPoint.y, maxPoint.x - minPoint.x, maxPoint.y - minPoint.y);
      Lib.current.stage.addChild(this.mShape);
    } else if (this.point != null) {
        // create min point and translate into global
        var minPoint:Point = new Point(this.x, this.y);
        minPoint.copyFrom(tilemap.localToGlobal(minPoint));
        // create max point and translate into global
        var maxPoint:Point = new Point(this.x + 1, this.y + 1);
        maxPoint.copyFrom(tilemap.localToGlobal(maxPoint));
        // generate shape
        this.mShape.graphics.drawRect(this.mMap.renderOffsetX + minPoint.x, this.mMap.renderOffsetY + minPoint.y, maxPoint.x - minPoint.x, maxPoint.y - minPoint.y);
        Lib.current.stage.addChild(this.mShape);
    } else {
      // create min point and translate into global
      var minPoint:Point = new Point(this.x, this.y);
      minPoint.copyFrom(tilemap.localToGlobal(minPoint));
      // create max point and translate into global
      var maxPoint:Point = new Point(this.x + this.width, this.y + this.height);
      maxPoint.copyFrom(tilemap.localToGlobal(maxPoint));
      // generate shape
      this.mShape.graphics.drawRect(this.mMap.renderOffsetX + minPoint.x, this.mMap.renderOffsetY + minPoint.y, maxPoint.x - minPoint.x, maxPoint.y - minPoint.y);
      Lib.current.stage.addChild(this.mShape);
    }
  }

  /**
   * Checks for collision
   * @param x
   * @param y
   * @param width
   * @param height
   * @return Bool
   */
  public function collides(x:Int, y:Int, width:Int, height:Int):Bool {
    // cache tilemap locally
    var tilemap:openfl.display.Tilemap = this.mMap.tilemap;
    // float buffer
    var buffer:Float = .1;
    // apply rendering offset for collision check
    x += this.mMap.renderOffsetX;
    y += this.mMap.renderOffsetY;
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
            var checkPoint:Point = new Point(x + tx, y + ty);
            checkPoint.copyFrom(tilemap.localToGlobal(checkPoint));
            // get distances
            var dist1:Float = Point.distance(checkPoint, linePoint1);
            var dist2:Float = Point.distance(checkPoint, linePoint2);
            // get line length
            var linelength:Float = Point.distance(linePoint1, linePoint2);
            // handle collision
            if (dist1 + dist2 >= linelength - buffer && dist1 + dist2 <= linelength + buffer) {
              #if openfl_tiled_render_objects
              this.render();
              #end
              return true;
            }
          }
        } else if (this.polygon != null) {
          /// FIXME: ADD LOGIC
        } else if (this.ellipse != null) {
          /// FIXME: ADD LOGIC
        } else if (this.point != null) {
          // create checkpoint and translate it into global
          var checkPoint:Point = new Point(x + tx, y + ty);
          checkPoint.copyFrom(tilemap.localToGlobal(checkPoint));
          // create point and translate into global
          var point:Point = new Point(this.x, this.y);
          point.copyFrom(tilemap.localToGlobal(point));
          // point collision check
          if (point.x == checkPoint.x && point.y == checkPoint.y) {
            #if openfl_tiled_render_objects
            this.render();
            #end
            return true;
          }
        } else {
          // create checkpoint and translate it into global
          var checkPoint:Point = new Point(x + tx, y + ty);
          checkPoint.copyFrom(tilemap.localToGlobal(checkPoint));
          // create min point and translate into global
          var minPoint:Point = new Point(this.x, this.y);
          minPoint.copyFrom(tilemap.localToGlobal(minPoint));
          // create max point and translate into global
          var maxPoint:Point = new Point(this.x + this.width, this.y + this.height);
          maxPoint.copyFrom(tilemap.localToGlobal(maxPoint));
          // regular rectangle collision check
          if (checkPoint.x >= minPoint.x && checkPoint.x <= maxPoint.x && checkPoint.y >= minPoint.y && checkPoint.y <= maxPoint.y) {
            #if openfl_tiled_render_objects
            this.render();
            #end
            return true;
          }
        }
      }
    }
    return false;
  }
}
