package openfl.tiled;

import openfl.events.EventDispatcher;
import openfl.tiled.map.StaggerIndex;
import openfl.tiled.map.StaggerAxis;
import openfl.tiled.map.RenderOrder;
import openfl.tiled.map.Orientation;
import openfl.errors.Error;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.events.Event;
import openfl.Lib;

class Map extends EventDispatcher {
  public var version(default, null):Float;
  public var tiledversion(default, null):Float;
  public var klass(default, null):String;
  public var orientation(default, null):Orientation;
  public var renderorder(default, null):RenderOrder;
  public var compressionlevel(default, null):Int;
  public var width(default, null):Int;
  public var height(default, null):Int;
  public var tilewidth(default, null):Int;
  public var tileheight(default, null):Int;
  public var hexsidelength(default, null):Int;
  public var staggeraxis(default, null):StaggerAxis;
  public var staggerindex(default, null):StaggerIndex;
  public var parallaxoriginx(default, null):Int;
  public var parallaxoriginy(default, null):Int;
  public var backgroundcolor(default, null):UInt;
  public var nextlayerid(default, null):Int;
  public var nextobjectid(default, null):Int;
  public var infinite(default, null):Int;
  public var tileset(default, null):Array<openfl.tiled.Tileset>;
  public var layer(default, null):Array<openfl.tiled.Layer>;
  public var objectgroup(default, null):Array<openfl.tiled.ObjectGroup>;
  public var imagelayer(default, null):Array<openfl.tiled.ImageLayer>;
  public var group(default, null):Array<openfl.tiled.Group>;

  public var isLoaded(default, null):Bool;
  public var prefix(default, null):String;
  public var tilemap(get, null):openfl.display.Tilemap;
  public var renderOffsetX(get, null):Int;
  public var renderOffsetY(get, null):Int;

  private var mTilesetLoaded:Bool;
  private var mImageLayerLoaded:Bool;
  private var mGroupLoaded:Bool;
  private var mPath:String;
  private var mTileMap:openfl.display.Tilemap;
  private var mRenderObjects:Array<openfl.tiled.Updatable>;
  private var mOffsetX:Int = -1;
  private var mOffsetY:Int = -1;

  /**
   * Constructor
   * @param prefix folder prefix used when loading additional assets internally
   * @param path full path to map
   * @param tilemap tilemap to use if ommitted one is created with stage size including resize handling
   */
  public function new(prefix:String, path:String, ?tilemap:Null<openfl.display.Tilemap>) {
    // call parent constructor
    super();
    // set variables
    this.mPath = path;
    this.prefix = prefix;
    this.isLoaded = false;
    this.mTileMap = tilemap;
    this.mTilesetLoaded = false;
    this.mImageLayerLoaded = false;
    this.mGroupLoaded = false;
    // initialize tilemap if not passed
    if (this.mTileMap == null) {
      // initialize tilemap
      this.mTileMap = new openfl.display.Tilemap(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
      // set added to and removed from stage
      this.mTileMap.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
      this.mTileMap.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    }
  }

  /**
   * Added to stage handler
   * @param event
   */
  private function onAddedToStage(event:Event):Void {
    // set resize handler
    this.mTileMap.stage.addEventListener(Event.RESIZE, this.onResize);
    // initially render the map
    this.render();
    // dispatch added to stage event
    this.dispatchEvent(new Event(Event.ADDED_TO_STAGE, false, false));
  }

  /**
   * Removed from stage handler
   * @param event
   */
  private function onRemovedFromStage(event:Event):Void {
    // remove set event listeners from tilemap
    this.mTileMap.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
    this.mTileMap.removeEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    // remove resize event listener
    this.mTileMap.stage.removeEventListener(Event.RESIZE, this.onResize);
    // dispatch removed from stage event
    this.dispatchEvent(new Event(Event.REMOVED_FROM_STAGE, false, false));
  }

  /**
   * Resize handler
   * @param event
   */
  private function onResize(event:Event):Void {
    // set width and height
    this.mTileMap.width = this.mTileMap.stage.stageWidth;
    this.mTileMap.height = this.mTileMap.stage.stageHeight;
    // cache offsets
    var previousOffsetX:Int = this.mOffsetX;
    var previousOffsetY:Int = this.mOffsetY;
    // reset to initial
    this.mOffsetX = -1;
    this.mOffsetY = -1;
    // render again
    this.render(previousOffsetX, previousOffsetY);
    // dispatch resize event
    this.dispatchEvent(new Event(Event.RESIZE, false, false));
  }

  /**
   * On load complete callback
   * @param event
   */
  private function onLoadComplete(event:Event):Void {
    // get url loader
    var loader:URLLoader = cast event.target;
    // remove on load complete handler
    loader.removeEventListener(Event.COMPLETE, onLoadComplete);
    // parse loaded data
    parseXml(loader.data);
    // initiate loading process
    this.loadData();
  }

  /**
   * Helper method to parse XML
   * @param xmlContent
   */
  private function parseXml(xmlContent:String):Void {
    var xmlParsed:Xml = Xml.parse(xmlContent).firstElement();
    // parse map
    this.version = Std.parseFloat(xmlParsed.get("version"));
    this.tiledversion = xmlParsed.exists("tiledversion") ? Std.parseFloat(xmlParsed.get("tiledversion")) : -1;
    this.klass = xmlParsed.exists("class") ? xmlParsed.get("class") : "";
    // parse orientation
    var o:String = xmlParsed.get("orientation");
    switch (o) {
      case "orthogonal":
        this.orientation = Orientation.MapOrientationOrthogonal;
      case "isometric":
        this.orientation = Orientation.MapOrientationIsometric;
      case "staggered":
        this.orientation = Orientation.MapOrientationStaggered;
      case "hexagonal":
        this.orientation = Orientation.MapOrientationHexagonal;
      default:
        throw new Error('Unsupported orientation $o');
    }
    // parse render order
    var r:String = xmlParsed.exists("renderorder") ? xmlParsed.get("renderorder") : "right-down";
    switch (r) {
      case "right-down":
        this.renderorder = RenderOrder.MapRenderOrderRightDown;
      case "right-up":
        this.renderorder = RenderOrder.MapRenderOrderRightUp;
      case "left-down":
        this.renderorder = RenderOrder.MapRenderOrderLeftDown;
      case "left-up":
        this.renderorder = RenderOrder.MapRenderOrderLeftUp;
    }
    this.compressionlevel = xmlParsed.exists("compressionlevel") ? Std.parseInt(xmlParsed.get("compressionlevel")) : -1;
    this.width = Std.parseInt(xmlParsed.get("width"));
    this.height = Std.parseInt(xmlParsed.get("height"));
    this.tilewidth = Std.parseInt(xmlParsed.get("tilewidth"));
    this.tileheight = Std.parseInt(xmlParsed.get("tileheight"));
    // handle only hexagonal stuff
    if (this.orientation == Orientation.MapOrientationHexagonal) {
      this.hexsidelength = Std.parseInt(xmlParsed.get("hexsidelength"));
    }
    // handle hexagonal / staggered stuff
    if (this.orientation == Orientation.MapOrientationHexagonal || this.orientation == Orientation.MapOrientationStaggered) {
      var axis:String = xmlParsed.get("staggeraxis");
      switch (axis) {
        case "x":
          this.staggeraxis = StaggerAxis.MapStaggerAxisX;
        case "y":
          this.staggeraxis = StaggerAxis.MapStaggerAxisY;
        default:
          throw new Error('Unsupported staggeraxis $axis');
      }
      var index:String = xmlParsed.get("staggerindex");
      switch (index) {
        case "even":
          this.staggerindex = StaggerIndex.MapStaggerIndexEven;
        case "odd":
          this.staggerindex = StaggerIndex.MapStaggerIndexOdd;
        default:
          throw new Error('Unsupported staggeraxis $index');
      }
    }
    this.parallaxoriginx = xmlParsed.exists("parallaxoriginx") ? Std.parseInt(xmlParsed.get("parallaxoriginx")) : 0;
    this.parallaxoriginy = xmlParsed.exists("parallaxoriginy") ? Std.parseInt(xmlParsed.get("parallaxoriginy")) : 0;
    this.backgroundcolor = xmlParsed.exists("backgroundcolor") ? Std.parseInt(StringTools.replace(xmlParsed.get("backgroundcolor"), "#", "0xFF")) : 0x00000000;
    this.nextlayerid = xmlParsed.exists("nextlayerid") ? Std.parseInt(xmlParsed.get("nextlayerid")) : -1;
    this.nextobjectid = xmlParsed.exists("nextobjectid") ? Std.parseInt(xmlParsed.get("nextobjectid")) : -1;
    this.infinite = xmlParsed.exists("infinite") ? Std.parseInt(xmlParsed.get("infinite")) : 0;
    // setup tileset, layer, objectgroup, imagelayer and group
    this.tileset = new Array<openfl.tiled.Tileset>();
    this.layer = new Array<openfl.tiled.Layer>();
    this.objectgroup = new Array<openfl.tiled.ObjectGroup>();
    this.imagelayer = new Array<openfl.tiled.ImageLayer>();
    this.group = new Array<openfl.tiled.Group>();
    // setup render objects array
    this.mRenderObjects = new Array<openfl.tiled.Updatable>();

    var layerId:Int = 0;
    for (child in xmlParsed) {
      if (child.nodeType != Xml.Element) {
        // skip non elements
        continue;
      }
      switch (child.nodeName) {
        case "tileset":
          var ts:openfl.tiled.Tileset = new openfl.tiled.Tileset(child, this);
          this.tileset.push(ts);
        case "layer":
          var l:openfl.tiled.Layer = new openfl.tiled.Layer(child, this, layerId++);
          this.layer.push(l);
          this.mRenderObjects.push(l);
        case "objectgroup":
          var o:openfl.tiled.ObjectGroup = new openfl.tiled.ObjectGroup(child, this);
          this.objectgroup.push(o);
          this.mRenderObjects.push(o);
        case "imagelayer":
          var i:openfl.tiled.ImageLayer = new openfl.tiled.ImageLayer(child, this);
          this.imagelayer.push(i);
          this.mRenderObjects.push(i);
        case "group":
          var g:openfl.tiled.Group = new openfl.tiled.Group(child, this);
          this.group.push(g);
          this.mRenderObjects.push(g);
      }
    }

    // determine and adjust max widths for infinite maps
    if (this.infinite == 1) {
      var maxWidth:Int = 0;
      var maxHeight:Int = 0;
      for (renderObject in this.mRenderObjects) {
        maxWidth = Std.int(Math.max(maxWidth, renderObject.evaluateWidth()));
        maxHeight = Std.int(Math.max(maxHeight, renderObject.evaluateHeight()));
      }
      // overwrite width and height property if greater
      if (maxWidth > this.width) {
        this.width = maxWidth;
      }
      if (maxHeight > this.height) {
        this.height = maxHeight;
        if (this.orientation == MapOrientationIsometric || this.orientation == MapOrientationStaggered) {
          this.height = Std.int(this.height / 2);
        }
      }
    }
  }

  /**
   * Set load callback
   */
  public function load():Void {
    #if openfl_tiled_use_asset
    // fake loader
    var loader:URLLoader = new URLLoader();
    loader.data = Assets.getText(mPath);
    // fake target
    var event:Event = new Event(Event.COMPLETE);
    Reflect.setField(event, "target", loader);
    // call on load complete
    onLoadComplete(event);
    #else
    var request:URLRequest = new URLRequest(mPath);
    var loader:URLLoader = new URLLoader();
    loader.addEventListener(Event.COMPLETE, onLoadComplete);
    loader.load(request);
    #end
  }

  /**
   * Load all necessary data
   */
  private function loadData():Void {
    if (!this.mTilesetLoaded) {
      var tmpTileset:Array<openfl.tiled.Tileset> = new Array<openfl.tiled.Tileset>();
      for (tileset in this.tileset) {
        tmpTileset.push(tileset);
      }
      // handle no tiles to be loaded
      if (0 >= tmpTileset.length) {
        this.mTilesetLoaded = true;
        this.loadData();
        return;
      }
      // loop through tilesets and start loading them
      for (tileset in this.tileset) {
        tileset.addEventListener(Event.COMPLETE, (event:Event) -> {
          tmpTileset.remove(tileset);
          // continue loading when end was reached
          if (0 >= tmpTileset.length) {
            this.mTilesetLoaded = true;
            // continue with load process
            this.loadData();
          }
        });
        // load tile
        tileset.load();
      }
    } else if (!this.mImageLayerLoaded) {
      var tmpImageLayer:Array<openfl.tiled.ImageLayer> = new Array<openfl.tiled.ImageLayer>();
      for (imagelayer in this.imagelayer) {
        tmpImageLayer.push(imagelayer);
      }
      // handle no tiles to be loaded
      if (0 >= tmpImageLayer.length) {
        this.mImageLayerLoaded = true;
        this.loadData();
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
            this.loadData();
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
        this.loadData();
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
            this.loadData();
          }
        });
        // load tile
        group.load();
      }
    } else {
      // set loaded flag
      this.isLoaded = true;
      // dispatch complete event
      this.dispatchEvent(new Event(Event.COMPLETE));
    }
  }

  /**
   * Helper to get tileset by gid
   * @param gid
   * @return openfl.tiled.Tileset
   */
  @:dox(hide) @:noCompletion public function tilesetByGid(gid:Int):openfl.tiled.Tileset {
    var tileset:openfl.tiled.Tileset = null;
    for (ts in this.tileset) {
      if (gid >= ts.firstgid) {
        tileset = ts;
      }
    }
    return tileset;
  }

  /**
   * Method renders map and returns tilemap to be added
   * @param offsetX
   * @param offsetY
   */
  public function render(offsetX:Int = 0, offsetY:Int = 0):Void {
    // handle no offset change
    if (this.mOffsetX == offsetX && this.mOffsetY == offsetY) {
      return;
    }
    // set previous offset x and y
    this.mOffsetX = offsetX;
    this.mOffsetY = offsetY;
    var index:Int = 0;
    // update render objects
    for (renderObject in this.mRenderObjects) {
      // update render object
      index += renderObject.update(offsetX, offsetY, index);
    }
  }

  /**
   * Getter for tilemap property
   * @return openfl.display.Tilemap
   */
  private function get_tilemap():openfl.display.Tilemap {
    return this.mTileMap;
  }

  /**
   * Getter for render offset X
   * @return Int
   */
  private function get_renderOffsetX():Int {
    return this.mOffsetX;
  }

  /**
   * Getter for render offset y
   * @return Int
   */
  private function get_renderOffsetY():Int {
    return this.mOffsetY;
  }

  /**
   * Helper to get objectgroup by name, e.g. for collision layer
   * @param name
   * @return openfl.tiled.ObjectGroup
   */
  public function objectgroupByName(name:String):openfl.tiled.ObjectGroup {
    for (objectgroup in this.objectgroup) {
      if (objectgroup.name == name) {
        return objectgroup;
      }
    }
    return null;
  }

  /**
   * Helper to check for collision
   * @param x global x coordinate start
   * @param y global y coordinate start
   * @param width width
   * @param height height
   * @return Bool
   */
  public function collides(x:Int, y:Int, width:Int, height:Int):Bool {
    for (renderObject in this.mRenderObjects) {
      if (renderObject.collides(x, y, width, height)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Helper to check whether object is visible or not
   * @param x
   * @param y
   * @param width
   * @param height
   * @return Bool
   */
  @:dox(hide) @:noCompletion public function willBeVisible(x:Int, y:Int, width:Int, height:Int):Bool {
    // build min and max point
    var maxPoint:openfl.geom.Point = new openfl.geom.Point(x + width, y + width);
    var minPoint:openfl.geom.Point = new openfl.geom.Point(x, y);
    // transform to global
    var globalMaxPoint = this.mTileMap.localToGlobal(maxPoint);
    var globalMinPoint = this.mTileMap.localToGlobal(minPoint);
    // check whether it's in tilemap width range
    return
      (
        globalMaxPoint.x >= 0
        && globalMaxPoint.x <= this.mTileMap.width
        && globalMaxPoint.y >= 0
        && globalMaxPoint.y <= this.mTileMap.height
      ) || (
        globalMinPoint.x >= 0
        && globalMinPoint.x <= this.mTileMap.width
        && globalMinPoint.y >= 0
        && globalMinPoint.y <= this.mTileMap.height
      );
  }
}
