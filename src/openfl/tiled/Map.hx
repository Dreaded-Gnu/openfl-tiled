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
  private var mTilesetLoad:Array<openfl.tiled.Tileset>;
  private var mPath:String;

  public function new(path:String) {
    // call parent constructor first
    super();
    // save path
    this.mPath = path;
    this.isLoaded = false;
  }

  /**
   * On load complete callback
   * @param event
   */
  private function onLoadComplete(event:Event) {
    // get loader
    var loader:URLLoader = cast(event.target, URLLoader);
    // remove event listener
    loader.removeEventListener(Event.COMPLETE, onLoadComplete);
    // parse XML
    parseXml(loader.data);
    // load tileset data
    this.loadTilesetData();
  }

  /**
   * Helper method to parse XML
   * @param xmlContent
   */
  private function parseXml(xmlContent:String) {
    // parse xml
    var xmlParsed:Xml = Xml.parse(xmlContent).firstElement();
    // parse map
    this.version = Std.parseFloat(xmlParsed.get("version"));
    this.tiledversion = xmlParsed.exists("tiledversion")
      ? Std.parseFloat(xmlParsed.get("tiledversion"))
      : -1;
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
    var r:String = xmlParsed.exists("renderorder")
      ? xmlParsed.get("renderorder")
      : "right-down";
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
    this.compressionlevel = xmlParsed.exists("compressionlevel")
      ? Std.parseInt(xmlParsed.get("compressionlevel"))
      : -1;
    this.width = Std.parseInt(xmlParsed.get("width"));
    this.height = Std.parseInt(xmlParsed.get("height"));
    this.tilewidth = Std.parseInt(xmlParsed.get("tilewidth"));
    this.tileheight = Std.parseInt(xmlParsed.get("tileheight"));
    // handle only hexagonal stuff
    if (this.orientation == Orientation.MapOrientationHexagonal) {
      this.hexsidelength = Std.parseInt(xmlParsed.get("hexsidelength"));
    }
    // handle hexagonal / staggered stuff
    if(
      this.orientation == Orientation.MapOrientationHexagonal
      || this.orientation == Orientation.MapOrientationStaggered
    ) {
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
    this.parallaxoriginx = xmlParsed.exists("parallaxoriginx")
      ? Std.parseInt(xmlParsed.get("parallaxoriginx"))
      : 0;
    this.parallaxoriginy = xmlParsed.exists("parallaxoriginy")
      ? Std.parseInt(xmlParsed.get("parallaxoriginy"))
      : 0;
    this.backgroundcolor = xmlParsed.exists("parallaxoriginy")
      ? Std.parseInt(
        StringTools.replace(xmlParsed.get("backgroundcolor"), "#", "0xFF")
      ) : 0x00000000;
    this.nextlayerid = xmlParsed.exists("nextlayerid")
      ? Std.parseInt(xmlParsed.get("nextlayerid"))
      : -1;
    this.nextobjectid = xmlParsed.exists("nextobjectid")
      ? Std.parseInt(xmlParsed.get("nextobjectid"))
      : -1;
    this.infinite = xmlParsed.exists("infinite")
      ? Std.parseInt(xmlParsed.get("infinite"))
      : 0;
    // setup tileset, layer, objectgroup, imagelayer and group
    this.tileset = new Array<openfl.tiled.Tileset>();
    this.layer = new Array<openfl.tiled.Layer>();
    this.objectgroup = new Array<openfl.tiled.ObjectGroup>();
    this.imagelayer = new Array<openfl.tiled.ImageLayer>();
    this.group = new Array<openfl.tiled.Group>();

    var layerId:Int = 0;
    for (child in xmlParsed) {
      // skip non elements
      if (child.nodeType != Xml.Element) {
        continue;
      }
      switch (child.nodeName) {
        case "tileset":
          tileset.push(new openfl.tiled.Tileset(child, this));
        case "layer":
          layer.push(new openfl.tiled.Layer(child, this, layerId++));
      }
    }
  }

  /**
   * Set load callback
   */
  public function load():Void {
    // build request
    var request:URLRequest = new URLRequest(mPath);
    // create url loader instance
    var loader:URLLoader = new URLLoader();
    // add load complete handler
    loader.addEventListener(Event.COMPLETE, onLoadComplete);
    // load created request
    loader.load(request);
  }

  /**
   * Load all necessary data
   */
  private function loadTilesetData():Void {
    // setup tileset load array
    this.mTilesetLoad = new Array<openfl.tiled.Tileset>();
    for (tileset in this.tileset) {
      this.mTilesetLoad.push(tileset);
    }
    // iterate through tilesets
    for (tileset in this.tileset) {
      // add eventlistener
      tileset.addEventListener(
        Event.COMPLETE,
        onTilesetLoadComplete.bind(_, tileset)
      );
      // kickstart loading
      tileset.load();
    }
  }

  /**
   * On tileset load complete
   * @param event
   * @param tileset
   */
  private function onTilesetLoadComplete(
    event:Event,
    tileset:openfl.tiled.Tileset
  ):Void {
    // remove event listener
    tileset.removeEventListener(
      Event.COMPLETE,
      onTilesetLoadComplete.bind(_, tileset)
    );
    // remove index from array
    this.mTilesetLoad.remove(tileset);
    // handle fully loaded
    if (0 >= this.mTilesetLoad.length) {
      this.dispatchEvent(new Event(Event.COMPLETE));
      this.isLoaded = true;
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
   * Render method renders to sprite for display purpose
   * @return Sprite
   */
  public function render(offsetX:Int = -1, offsetY:Int = -1):Sprite {
    // generate sprite for rendering
    var displayObject:Sprite = new Sprite();

    for(layer in this.layer) {
      layer.render(displayObject, offsetX, offsetY);
    }
    // return display object
    return displayObject;
  }
}
