package openfl.tiled;

import openfl.events.Event;
import openfl.events.EventDispatcher;

/**
 * Tiled group representation
 */
class Group extends EventDispatcher implements openfl.tiled.Updatable {
  /**
   * Group id
   */
  public var id(default, null):Int;

  /**
   * Group name
   */
  public var name(default, null):String;

  /**
   * Class
   */
  public var klass(default, null):String;

  /**
   * Offset on x axis
   */
  public var offsetx(default, null):Int;

  /**
   * Offset on y axis
   */
  public var offsety(default, null):Int;

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
   * Object properties
   */
  public var properties(default, null):openfl.tiled.Properties;

  /**
   * Object layer
   */
  public var layer(default, null):Array<openfl.tiled.Layer>;

  /**
   * Object group
   */
  public var objectgroup(default, null):Array<openfl.tiled.ObjectGroup>;

  /**
   * Image layer
   */
  public var imagelayer(default, null):Array<openfl.tiled.ImageLayer>;

  /**
   * Nested groups
   */
  public var group(default, null):Array<openfl.tiled.Group>;

  private var mMap:openfl.tiled.Map;
  private var mRenderObjects:Array<openfl.tiled.Updatable>;
  private var mImageLayerLoaded:Bool;
  private var mGroupLoaded:Bool;

  /**
   * Constructor
   * @param node xml representation to parse
   * @param map map this group belongs to
   */
  public function new(node:Xml, map:openfl.tiled.Map) {
    super();
    // cache map
    this.mMap = map;
    // parse attributes
    this.id = node.exists("id") ? Std.parseInt(node.get("id")) : 0;
    this.name = node.exists("name") ? node.get("name") : "";
    this.klass = node.exists("class") ? node.get("class") : "";
    this.offsetx = node.exists("offsetx") ? Std.parseInt(node.get("offsetx")) : 0;
    this.offsety = node.exists("offsety") ? Std.parseInt(node.get("offsety")) : 0;
    this.opacity = node.exists("opacity") ? Std.parseFloat(node.get("opacity")) : 0;
    this.visible = node.exists("visible") ? Std.parseInt(node.get("visible")) : 0;
    this.tintcolor = node.get("tintcolor");
    // initialize arrays
    this.layer = new Array<openfl.tiled.Layer>();
    this.objectgroup = new Array<openfl.tiled.ObjectGroup>();
    this.imagelayer = new Array<openfl.tiled.ImageLayer>();
    this.group = new Array<openfl.tiled.Group>();
    // setup render objects array
    this.mRenderObjects = new Array<openfl.tiled.Updatable>();
    // parse children
    for (child in node) {
      if (child.nodeType != Xml.Element) {
        // skip non elements
        continue;
      }
      switch (child.nodeName) {
        case "properties":
          this.properties = new openfl.tiled.Properties(child);
        case "layer":
          var l:openfl.tiled.Layer = new openfl.tiled.Layer(child, this.mMap, 0);
          this.layer.push(l);
          this.mRenderObjects.push(l);
        case "objectgroup":
          var o:openfl.tiled.ObjectGroup = new openfl.tiled.ObjectGroup(child, this.mMap);
          this.objectgroup.push(o);
          this.mRenderObjects.push(o);
        case "imagelayer":
          var i:openfl.tiled.ImageLayer = new openfl.tiled.ImageLayer(child, this.mMap);
          this.imagelayer.push(i);
          this.mRenderObjects.push(i);
        case "group":
          var g:openfl.tiled.Group = new openfl.tiled.Group(child, this.mMap);
          this.group.push(g);
          this.mRenderObjects.push(g);
      }
    }
  }

  /**
   * Update method
   * @param offsetX
   * @param offsetY
   * @param index
   * @return Int
   */
  @:dox(hide) @:noCompletion public function update(offsetX:Int, offsetY:Int, index:Int):Int {
    // initialize total
    var total:Int = 0;
    // iterate through render objects and perform an update
    for (renderObject in this.mRenderObjects) {
      // update render object and increment total
      total += renderObject.update(offsetX, offsetY, index + total);
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
  @:dox(hide) @:noCompletion public function collides(x:Int, y:Int, width:Int, height:Int):Bool {
    for (renderObject in this.mRenderObjects) {
      if (renderObject.collides(x, y, width, height)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Helper to evaluate width
   * @return Int
   */
  @:dox(hide) @:noCompletion public function evaluateWidth():Int {
    var width:Int = 0;
    for (renderObject in this.mRenderObjects) {
      width = Std.int(Math.max(width, renderObject.evaluateWidth()));
    }
    return width;
  }

  /**
   * Helper to evaluate height
   * @return Int
   */
  @:dox(hide) @:noCompletion public function evaluateHeight():Int {
    var height:Int = 0;
    for (renderObject in this.mRenderObjects) {
      height = Std.int(Math.max(height, renderObject.evaluateHeight()));
    }
    return height;
  }

  /**
   * Load method
   */
  @:dox(hide) @:noCompletion public function load():Void {
    if (!this.mImageLayerLoaded) {
      var tmpImageLayer:Array<openfl.tiled.ImageLayer> = new Array<openfl.tiled.ImageLayer>();
      for (imagelayer in this.imagelayer) {
        tmpImageLayer.push(imagelayer);
      }
      // handle no tiles to be loaded
      if (0 >= tmpImageLayer.length) {
        this.mImageLayerLoaded = true;
        this.load();
        return;
      }
      // loop through tiles and start loading them
      for (imagelayer in this.imagelayer) {
        imagelayer.addEventListener(Event.COMPLETE, (event:Event) -> {
          tmpImageLayer.remove(imagelayer);
          // continue loading when end was reached
          if (0 >= tmpImageLayer.length) {
            this.mImageLayerLoaded = true;
            // continue with load process
            this.load();
          }
        });
        // load tile
        imagelayer.load();
      }
    } else if (!this.mGroupLoaded) {
      var tmpGroup:Array<openfl.tiled.Group> = new Array<openfl.tiled.Group>();
      for (group in this.group) {
        tmpGroup.push(group);
      }
      // handle no tiles to be loaded
      if (0 >= tmpGroup.length) {
        this.mGroupLoaded = true;
        this.load();
        return;
      }
      // loop through tiles and start loading them
      for (group in this.group) {
        group.addEventListener(Event.COMPLETE, (event:Event) -> {
          tmpGroup.remove(group);
          // continue loading when end was reached
          if (0 >= tmpGroup.length) {
            this.mGroupLoaded = true;
            // continue with load process
            this.load();
          }
        });
        // load tile
        group.load();
      }
    } else {
      // dispatch complete event
      this.dispatchEvent(new Event(Event.COMPLETE));
    }
  }
}
