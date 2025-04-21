package tiledfl;

import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.errors.Error;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import tiledfl.map.StaggerIndex;
import tiledfl.map.StaggerAxis;
import tiledfl.map.RenderOrder;
import tiledfl.map.Orientation;

/**
 * Map class for loading and rendering tilemap
 */
class Map extends EventDispatcher {
  private static inline var TILEMAP_RENDER_OFFSET_FACTOR:Int = 2;
  private static inline var TILEMAP_RENDER_MIN_FACTOR:Float = 1;
  #if tiledfl_debug_render_object
  private static inline var TILEMAP_DEFAULT_DEBUG_RENDER_COLOR:Int = 0xff0000;
  #end

  /**
   * TMX map format version
   */
  public var version(default, null):Float;

  /**
   * Tiled editor version used to safe the map
   */
  public var tiledversion(default, null):Float;

  /**
   * class
   */
  public var klass(default, null):String;

  /**
   * Orientation
   */
  public var orientation(default, null):Orientation;

  /**
   * Render order
   */
  public var renderorder(default, null):RenderOrder;

  /**
   * Compression level
   */
  public var compressionlevel(default, null):Int;

  /**
   * Map width
   */
  public var width(default, null):Int;

  /**
   * Map height
   */
  public var height(default, null):Int;

  /**
   * Tile width
   */
  public var tilewidth(default, null):Int;

  /**
   * Tile height
   */
  public var tileheight(default, null):Int;

  /**
   * Width and height of tiles edge in pixel, only for hexagonal maps
   */
  public var hexsidelength(default, null):Int;

  /**
   * Stagger axis for staggered and hexagonal maps
   */
  public var staggeraxis(default, null):StaggerAxis;

  /**
   * Stagger index for staggered and hexagonal maps
   */
  public var staggerindex(default, null):StaggerIndex;

  /**
   * X coordinate of parallax origin in pixel
   */
  public var parallaxoriginx(default, null):Int;

  /**
   * Y coordinate of parallax origin in pixel
   */
  public var parallaxoriginy(default, null):Int;

  /**
   * Background color
   */
  public var backgroundcolor(default, null):UInt;

  /**
   * Next available id for new layers
   */
  public var nextlayerid(default, null):Int;

  /**
   * Next available id for new objects
   */
  public var nextobjectid(default, null):Int;

  /**
   * Is infinite / chunked map
   */
  public var infinite(default, null):Int;

  /**
   * Array of tilesets
   */
  public var tileset(default, null):Array<tiledfl.Tileset>;

  /**
   * Array of layers
   */
  public var layer(default, null):Array<tiledfl.Layer>;

  /**
   * Array of object groups
   */
  public var objectgroup(default, null):Array<tiledfl.ObjectGroup>;

  /**
   * Array of image layers
   */
  public var imagelayer(default, null):Array<tiledfl.ImageLayer>;

  /**
   * Array of groups
   */
  public var group(default, null):Array<tiledfl.Group>;

  /**
   * Is fully loaded flag
   */
  public var isLoaded(default, null):Bool;

  /**
   * Used prefix folder
   */
  public var prefix(default, null):String;

  /**
   * Openfl tilemap instance
   */
  public var tilemap(get, null):openfl.display.Tilemap;

  /**
   * Render offset x
   */
  @:dox(hide) @:noCompletion public var renderOffsetX(get, null):Int;

  /**
   * Render offset y
   */
  @:dox(hide) @:noCompletion public var renderOffsetY(get, null):Int;

  #if tiledfl_debug_render_object
  /**
   * Debug render object color
   */
  public var debugRenderObjectColor(default, default):Int;
  #end

  private var mTilesetLoaded:Bool;
  private var mImageLayerLoaded:Bool;
  private var mGroupLoaded:Bool;
  private var mPath:String;
  private var mTileMap:openfl.display.Tilemap;
  private var mRenderObjects:Array<tiledfl.Updatable>;
  private var mOffsetX:Int;
  private var mOffsetY:Int;
  private var mPreviousOffsetX:Int;
  private var mPreviousOffsetY:Int;
  private var mRenderOffsetX:Int;
  private var mRenderOffsetY:Int;
  private var mRendered:Bool;

  /**
   * Constructor
   * @param prefix folder prefix used when loading additional assets internally
   * @param path full path to map
   * @param width tilemap width
   * @param height tilemap height
   */
  public function new(prefix:String, path:String, width:Int, height:Int) {
    // call parent constructor
    super();
    // set variables
    this.mPath = path;
    this.prefix = prefix;
    this.isLoaded = false;
    this.mTilesetLoaded = false;
    this.mImageLayerLoaded = false;
    this.mGroupLoaded = false;
    this.mOffsetX = 0;
    this.mOffsetY = 0;
    this.mPreviousOffsetX = 0;
    this.mPreviousOffsetY = 0;
    this.mRenderOffsetX = 0;
    this.mRenderOffsetY = 0;
    this.mRendered = false;
    // set public properties if needed
    #if tiledfl_debug_render_object
    this.debugRenderObjectColor = TILEMAP_DEFAULT_DEBUG_RENDER_COLOR;
    #end
    // initialize tilemap
    this.mTileMap = new openfl.display.Tilemap(width * TILEMAP_RENDER_OFFSET_FACTOR, height * TILEMAP_RENDER_OFFSET_FACTOR, null, false);
    // set added to and removed from stage
    this.mTileMap.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
    this.mTileMap.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemovedFromStage);
    // set cache as bitmap flag and a scroll rectangle
    this.mTileMap.scrollRect = new Rectangle(0, 0, width, height);
  }

  /**
   * Added to stage handler
   * @param event
   */
  private function onAddedToStage(event:Event):Void {
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
    // dispatch removed from stage event
    this.dispatchEvent(new Event(Event.REMOVED_FROM_STAGE, false, false));
  }

  /**
   * Resize function. Emits resize event after resize and scroll rect generation
   * @param width width to resize tilemap to
   * @param height height to resize tilemap to
   */
  public function resize(width:Int, height:Int):Void {
    // resize tilemap
    this.mTileMap.width = width * TILEMAP_RENDER_OFFSET_FACTOR;
    this.mTileMap.height = height * TILEMAP_RENDER_OFFSET_FACTOR;
    // setup new scroll rect
    this.mTileMap.scrollRect = new Rectangle(0, 0, width, height);
    // render again
    this.mRendered = false;
    this.render();
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
    this.tileset = new Array<tiledfl.Tileset>();
    this.layer = new Array<tiledfl.Layer>();
    this.objectgroup = new Array<tiledfl.ObjectGroup>();
    this.imagelayer = new Array<tiledfl.ImageLayer>();
    this.group = new Array<tiledfl.Group>();
    // setup render objects array
    this.mRenderObjects = new Array<tiledfl.Updatable>();

    var layerId:Int = 0;
    for (child in xmlParsed) {
      if (child.nodeType != Xml.Element) {
        // skip non elements
        continue;
      }
      switch (child.nodeName) {
        case "tileset":
          var ts:tiledfl.Tileset = new tiledfl.Tileset(child, this);
          this.tileset.push(ts);
        case "layer":
          var l:tiledfl.Layer = new tiledfl.Layer(child, this, layerId++);
          this.layer.push(l);
          this.mRenderObjects.push(l);
        case "objectgroup":
          var o:tiledfl.ObjectGroup = new tiledfl.ObjectGroup(child, this);
          this.objectgroup.push(o);
          this.mRenderObjects.push(o);
        case "imagelayer":
          var i:tiledfl.ImageLayer = new tiledfl.ImageLayer(child, this);
          this.imagelayer.push(i);
          this.mRenderObjects.push(i);
        case "group":
          var g:tiledfl.Group = new tiledfl.Group(child, this);
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
   * Method to start loading process of map
   */
  public function load():Void {
    #if tiledfl_use_asset
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
      var tmpTileset:Array<tiledfl.Tileset> = new Array<tiledfl.Tileset>();
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
      var tmpImageLayer:Array<tiledfl.ImageLayer> = new Array<tiledfl.ImageLayer>();
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
      var tmpGroup:Array<tiledfl.Group> = new Array<tiledfl.Group>();
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
   * @return tiledfl.Tileset
   */
  @:dox(hide) @:noCompletion public function tilesetByGid(gid:Int):tiledfl.Tileset {
    var tileset:tiledfl.Tileset = null;
    for (ts in this.tileset) {
      if (gid >= ts.firstgid) {
        tileset = ts;
      }
    }
    return tileset;
  }

  /**
   * Method to render tilemap
   * @param offsetX x offset to be considered
   * @param offsetY y offset to be considered
   */
  public function render(offsetX:Int = 0, offsetY:Int = 0):Void {
    // skip render if not loaded!
    if (!this.isLoaded) {
      return;
    }
    // handle no offset change
    if (this.mOffsetX == offsetX && this.mOffsetY == offsetY && this.mRendered) {
      return;
    }
    // set previous offset x and y
    this.mOffsetX = offsetX;
    this.mOffsetY = offsetY;
    // get scroll rectangle
    var rect:Rectangle = this.mTileMap.scrollRect;
    // update scroll rect
    rect.x -= this.mPreviousOffsetX - this.mOffsetX;
    rect.y -= this.mPreviousOffsetY - this.mOffsetY;
    // calculate borders when to render
    var minWidthPos:Float = this.mTileMap.width / TILEMAP_RENDER_OFFSET_FACTOR * TILEMAP_RENDER_MIN_FACTOR;
    var minHeightPos:Float = this.mTileMap.height / TILEMAP_RENDER_OFFSET_FACTOR * TILEMAP_RENDER_MIN_FACTOR;
    // update render objects if it wasn't rendered yet or some threshold is reached
    if (!this.mRendered || rect.x > minWidthPos || rect.y > minHeightPos || rect.x < 0 || rect.y < 0) {
      // new rect x and y will by default be the one set
      var newRectX:Float = rect.x;
      var newRectY:Float = rect.y;
      // determine new render offsets
      if (!this.mRendered) {
        // handle not rendered by using offset minus min width divided by two
        this.mRenderOffsetX = Std.int(Math.max(this.mOffsetX - minWidthPos / 2, 0));
        // adjust rect x position
        newRectX /= 2;
      } else if (rect.x > minWidthPos) {
        // increment render offset
        this.mRenderOffsetX += Std.int(rect.x / 2);
        // adjust rect x position
        newRectX /= 2;
      } else if (rect.x < 0) {
        // determine new rect x
        newRectX = minWidthPos / 2;
        // calculate new render offset
        var newRenderOffsetX = Std.int(Math.max(this.mRenderOffsetX - minWidthPos / 2, 0));
        // handle offset turns to 0
        if (newRenderOffsetX == 0) {
          // adjust new rect x by adding difference
          newRectX += (this.mRenderOffsetX - minWidthPos / 2);
        }
        // set new render offset
        this.mRenderOffsetX = newRenderOffsetX;
      }
      if (!this.mRendered) {
        // handle not rendered by using offset minus min height divided by two
        this.mRenderOffsetY = Std.int(Math.max(this.mOffsetY - minHeightPos / 2, 0));
        // adjust rect x position
        newRectY /= 2;
      } else if (rect.y > minHeightPos) {
        // increment render offset
        this.mRenderOffsetY += Std.int(rect.y / 2);
        // adjust rect x position
        newRectY /= 2;
      } else if (rect.y < 0) {
        // determine new rect x
        newRectY = minHeightPos / 2;
        // calculate new render offset
        var newRenderOffsetY = Std.int(Math.max(this.mRenderOffsetY - minHeightPos / 2, 0));
        // handle offset turns to 0
        if (newRenderOffsetY == 0) {
          // adjust new rect y by adding difference
          newRectY += (this.mRenderOffsetY - minHeightPos / 2);
        }
        // set new render offset
        this.mRenderOffsetY = newRenderOffsetY;
      }
      // setup index for render object update to keep the render order from tiled
      var index:Int = 0;
      // iterate over render objects
      for (renderObject in this.mRenderObjects) {
        // update render object
        index += renderObject.update(this.mRenderOffsetX, this.mRenderOffsetY, index);
      }
      // set to new rect positions
      rect.x = newRectX;
      rect.y = newRectY;
    }
    // write back scroll rect
    this.mTileMap.scrollRect = rect;
    // set previous x and y
    this.mPreviousOffsetX = this.mOffsetX;
    this.mPreviousOffsetY = this.mOffsetY;
    // set rendered flag
    this.mRendered = true;
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
   * @param name object group name to lookup
   * @return Object group with the name or null if not found
   */
  public function objectgroupByName(name:String):tiledfl.ObjectGroup {
    for (objectgroup in this.objectgroup) {
      if (objectgroup.name == name) {
        return objectgroup;
      }
    }
    return null;
  }

  /**
   * Helper to check for collision. Coordinates, width and height need to be scale less
   * @param x display x coordinate
   * @param y display y coordinate
   * @param width width
   * @param height height
   * @return True if collision was detected, else false
   */
  public function collides(x:Int, y:Int, width:Int, height:Int):Bool {
    // skip render if not loaded!
    if (!this.isLoaded) {
      return false;
    }
    // loop through render objects
    for (renderObject in this.mRenderObjects) {
      // check for collision
      if (renderObject.collides(x, y, width, height)) {
        return true;
      }
    }
    // no collision detected
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
    var maxPoint:Point = new Point(x + width + this.mTileMap.scrollRect.x, y + width + this.mTileMap.scrollRect.y);
    var minPoint:Point = new Point(x + this.mTileMap.scrollRect.x, y + this.mTileMap.scrollRect.y);
    // transform to global
    maxPoint.copyFrom(this.mTileMap.localToGlobal(maxPoint));
    minPoint.copyFrom(this.mTileMap.localToGlobal(minPoint));
    // calculate width and height with offset
    var width:Float = this.mTileMap.width;
    var height:Float = this.mTileMap.height;
    // check whether it's in tilemap width range
    return (maxPoint.x >= 0 && maxPoint.x <= width && maxPoint.y >= 0 && maxPoint.y <= height)
      || (minPoint.x >= 0 && minPoint.x <= width && minPoint.y >= 0 && minPoint.y <= height);
  }
}
