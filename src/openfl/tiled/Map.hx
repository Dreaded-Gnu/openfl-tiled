package openfl.tiled;

import openfl.display.Sprite;
import openfl.events.EventDispatcher;
import openfl.tiled.map.StaggerIndex;
import openfl.tiled.map.StaggerAxis;
import openfl.tiled.map.RenderOrder;
import openfl.tiled.map.Orientation;
import openfl.errors.Error;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.events.Event;

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

  private var mTilesetLoaded:Bool;
  private var mImageLayerLoaded:Bool;
  private var mGroupLoaded:Bool;
  private var mPath:String;
  private var mTileMap:openfl.display.Tilemap;
  private var mRenderObjects:Array<openfl.tiled.Updatable>;

  /**
   * Constructor
   * @param prefix folder prefix used when loading additional assets internally
   * @param path full path to map
   * @param width openfl stage width
   * @param height openfl stage height
   */
  public function new(prefix:String, path:String, tilemap:openfl.display.Tilemap) {
    super();
    this.mPath = path;
    this.prefix = prefix;
    this.isLoaded = false;
    this.mTileMap = tilemap;
    this.mTilesetLoaded = false;
    this.mImageLayerLoaded = false;
    this.mGroupLoaded = false;
  }

  /**
   * On load complete callback
   * @param event
   */
  private function onLoadComplete(event:Event):Void {
    var loader:URLLoader = cast(event.target, URLLoader);
    loader.removeEventListener(Event.COMPLETE, onLoadComplete);
    parseXml(loader.data);
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
      // loop through all layers
      for (layer in this.layer) {
        for (chunk in layer.data.chunk) {
          if (chunk.x + chunk.width > maxWidth) {
            // check for new max width
            maxWidth = chunk.x + chunk.width;
          }
          if (chunk.y + chunk.height > maxHeight) {
            // check for new map height
            maxHeight = chunk.y + chunk.height;
          }
        }
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
    var request:URLRequest = new URLRequest(mPath);
    var loader:URLLoader = new URLLoader();
    loader.addEventListener(Event.COMPLETE, onLoadComplete);
    loader.load(request);
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
  public function tilesetByGid(gid:Int):openfl.tiled.Tileset {
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
   * @param previousOffsetX
   * @param previousOffsetY
   * @return openfl.display.Tilemap
   */
  public function render(offsetX:Int = 0, offsetY:Int = 0, previousOffsetX:Int = 0, previousOffsetY:Int = 0):openfl.display.Tilemap {
    for (renderObject in this.mRenderObjects) {
      renderObject.update(this.mTileMap, offsetX, offsetY, previousOffsetX, previousOffsetY);
    }
    // return display object
    return this.mTileMap;
  }

  /**
   * Getter for tilemap property
   * @return openfl.display.Tilemap
   */
  private function get_tilemap():openfl.display.Tilemap {
    return this.mTileMap;
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
   * @param x start x
   * @param y start y
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
}
