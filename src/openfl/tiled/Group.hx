package openfl.tiled;

import openfl.events.Event;
import openfl.events.EventDispatcher;

class Group extends EventDispatcher implements openfl.tiled.Updatable {
  public var id(default, null):Int;
  public var name(default, null):String;
  public var klass(default, null):String;
  public var offsetx(default, null):Int;
  public var offsety(default, null):Int;
  public var opacity(default, null):Float;
  public var visible(default, null):Int;
  public var tintcolor(default, null):String;
  public var properties(default, null):openfl.tiled.Properties;
  public var layer(default, null):Array<openfl.tiled.Layer>;
  public var objectgroup(default, null):Array<openfl.tiled.ObjectGroup>;
  public var imagelayer(default, null):Array<openfl.tiled.ImageLayer>;
  public var group(default, null):Array<openfl.tiled.Group>;

  private var mMap:openfl.tiled.Map;
  private var mRenderObjects:Array<openfl.tiled.Updatable>;
  private var mImageLayerLoaded:Bool;
  private var mGroupLoaded:Bool;

  /**
   * Constructor
   * @param node
   * @param map
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
   * @param tilemap
   * @param offsetX
   * @param offsetY
   * @param previousOffsetX
   * @param previousOffsetY
   */
  public function update(tilemap:openfl.display.Tilemap, offsetX:Int, offsetY:Int, previousOffsetX:Int, previousOffsetY:Int):Void {
    for (renderObject in this.mRenderObjects) {
      renderObject.update(this.mMap.tilemap, offsetX, offsetY, previousOffsetX, previousOffsetY);
    }
  }

  /**
   * Load method
   */
  public function load():Void {
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
