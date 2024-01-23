package openfl.tiled;

import openfl.net.URLRequest;
import openfl.net.URLLoader;
import openfl.geom.Rectangle;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.tiled.tileset.FillMode;
import openfl.tiled.tileset.TileRenderSize;
import openfl.tiled.tileset.ObjectAlignment;
import openfl.tiled.map.Orientation;

class Tileset extends EventDispatcher {
  public var firstgid(default, null):Int;
  public var source(default, null):String;
  public var name(default, null):String;
  public var klass(default, null):String;
  public var tilewidth(default, null):Int;
  public var tileheight(default, null):Int;
  public var spacing(default, null):Int;
  public var margin(default, null):Int;
  public var tilecount(default, null):Int;
  public var columns(default, null):Int;
  public var objectalignment(default, null):ObjectAlignment;
  public var tilerendersize(default, null):TileRenderSize;
  public var fillmode(default, null):FillMode;
  public var image(default, null):openfl.tiled.Image;
  public var tileoffset(default, null):openfl.tiled.tileset.TileOffset;
  public var grid(default, null):openfl.tiled.tileset.Grid;
  public var properties(default, null):openfl.tiled.Properties;
  public var terraintypes(default, null):openfl.tiled.tileset.TerrainTypes;
  public var wangset(default, null):openfl.tiled.tileset.Wangsets;
  public var transformations(default, null):openfl.tiled.tileset.Transformations;
  public var tile(default, null):std.Map<Int, openfl.tiled.tileset.Tile>;

  public var tileset(default, null):openfl.display.Tileset;
  private var mSourceLoaded:Bool = false;
  private var mTileLoaded:Bool = false;
  private var mMap:openfl.tiled.Map;

  /**
   * Constructor
   * @param node
   */
  public function new(node:Xml, map:openfl.tiled.Map) {
    // call parent constructor
    super();
    // cache map
    this.mMap = map;
    // parse stuff
    this.parse(node);
  }

  /**
   * Helper to parse
   * @param node
   */
  private function parse(node:Xml):Void {
    // parse stuff
    this.firstgid = node.exists("firstgid")
      ? Std.parseInt(node.get("firstgid"))
      : this.firstgid;
    this.source = node.exists("source")
      ? node.get("source")
      : this.source;
    this.name = node.get("name");
    this.klass = node.exists("class")
      ? node.get("class")
      : "";
    this.tilewidth = Std.parseInt(node.get("tilewidth"));
    this.tileheight = Std.parseInt(node.get("tileheight"));
    this.spacing = node.exists("spacing")
      ? Std.parseInt(node.get("spacing"))
      : 0;
    this.margin = node.exists("margin")
      ? Std.parseInt(node.get("margin"))
      : 0;
    this.tilecount = node.exists("tilecount")
      ? Std.parseInt(node.get("tilecount"))
      : -1;
    this.columns = node.exists("columns")
      ? Std.parseInt(node.get("columns"))
      : -1;
    var o:String = node.get("objectalignment");
    switch (o) {
      case "unspecified":
        this.objectalignment = this.mMap.orientation == Orientation.MapOrientationOrthogonal
          ? ObjectAlignment.TilesetObjectAlignmentBottomLeft
          : ObjectAlignment.TilesetObjectAlignmentBottom;
      case "topleft":
        this.objectalignment = ObjectAlignment.TilesetObjectAlignmentTopLeft;
      case "top":
        this.objectalignment = ObjectAlignment.TilesetObjectAlignmentTop;
      case "topright":
        this.objectalignment = ObjectAlignment.TilesetObjectAlignmentTopRight;
      case "left":
        this.objectalignment = ObjectAlignment.TilesetObjectAlignmentLeft;
      case "center":
        this.objectalignment = ObjectAlignment.TilesetObjectAlignmentCenter;
      case "right":
        this.objectalignment = ObjectAlignment.TilesetObjectAlignmentRight;
      case "bottomleft":
        this.objectalignment = ObjectAlignment.TilesetObjectAlignmentBottomLeft;
      case "bottom":
        this.objectalignment = ObjectAlignment.TilesetObjectAlignmentBottom;
      case "bottomright":
        this.objectalignment = ObjectAlignment.TilesetObjectAlignmentBottomRight;
      default:
        this.objectalignment = this.mMap.orientation == Orientation.MapOrientationOrthogonal
          ? ObjectAlignment.TilesetObjectAlignmentBottomLeft
          : ObjectAlignment.TilesetObjectAlignmentBottom;
    }
    var tr:String = node.exists("tilerendersize")
      ? node.get("tilerendersize")
      : "tile";
    switch (tr) {
      case "tile":
        this.tilerendersize = TileRenderSize.TilesetTileRenderSizeTile;
      case "grid":
        this.tilerendersize = TileRenderSize.TilesetTileRenderSizeGrid;
    }
    var fm:String = node.exists("fillmode")
      ? node.get("fillmode")
      : "stretch";
    switch (fm) {
      case "stretch":
        this.fillmode = FillMode.TilesetFillModeStretch;
      case "preserve-aspect-fit":
        this.fillmode = FillMode.TilesetFillModePreserveAspectFit;
    }

    // initialize arrays
    this.tile = new std.Map<Int, openfl.tiled.tileset.Tile>();
    // loop through children
    for (child in node) {
      if (child.nodeType != Xml.Element) {
        continue;
      }

      switch (child.nodeName) {
        case "image":
          this.image = new openfl.tiled.Image(child, this.mMap);
        case "tile":
          this.tile.set(
            Std.parseInt(child.get("id")),
            new openfl.tiled.tileset.Tile(child, this.mMap)
          );
        case "tileoffset":
          this.tileoffset = new openfl.tiled.tileset.TileOffset(child);
        case "grid":
          this.grid = new openfl.tiled.tileset.Grid(child);
        case "properties":
          this.properties = new openfl.tiled.Properties(child);
        case "terraintypes":
        case "wangset":
        case "transformations":
      }
    }

    if (this.tileoffset == null) {
      this.tileoffset = new openfl.tiled.tileset.TileOffset(null);
    }
  }

  /**
   * Helper to get tile by gid
   * @param gid
   * @return openfl.tiled.tileset.Tile
   */
  private function getTileByGid(gid:Int):openfl.tiled.tileset.Tile {
    for(tile in this.tile) {
      if (tile.id == gid) {
        return tile;
      }
    }
    return null;
  }

  /**
   * Load callback
   */
  public function load():Void {
    if (!this.mSourceLoaded && this.source != null) {
      // load source file
      var request:URLRequest = new URLRequest(
        Helper.joinPath(
          this.mMap.prefix,
          this.source
        )
      );
      var loader:URLLoader = new URLLoader();
      // set load complete callback
      loader.addEventListener(Event.COMPLETE, (event:Event) -> {
        // rerun parsing
        this.parse(Xml.parse(loader.data).firstElement());
        // set loaded to true
        this.mSourceLoaded = true;
        // continue loading
        this.load();
      });
      loader.load(request);
    } else if (!this.mTileLoaded) {
      // put all tiles into temporary array
      var tmpTile:Array<openfl.tiled.tileset.Tile> = new Array<openfl.tiled.tileset.Tile>();
      for (tile in this.tile) {
        tmpTile.push(tile);
      }
      // handle no tiles to be loaded
      if (0 >= tmpTile.length) {
        this.mTileLoaded = true;
        this.load();
        return;
      }
      // loop through tiles and start loading them
      for (tile in this.tile) {
        tile.addEventListener(Event.COMPLETE, (event:Event)-> {
          // remove loaded tile
          tmpTile.remove(tile);
          // continue loading when end was reached
          if (0 >= tmpTile.length) {
            // set tile loaded to true
            this.mTileLoaded = true;
            // continue with load process
            this.load();
          }
        });
        // load tile
        tile.load();
      }
    } else if (this.image != null) {
      // add complete listener
      this.image.addEventListener(Event.COMPLETE, onImageCompleted);
      // load image
      this.image.load();
    } else {
      // nothing to do, dispatch complete
      this.dispatchEvent(new Event(Event.COMPLETE));
    }
  }

  /**
   * Callback for on image completed
   * @param event
   */
  private function onImageCompleted(event:Event):Void {
    // remove event listener
    this.image.removeEventListener(Event.COMPLETE, onImageCompleted);
    // parse tileset
    var txlen:Int = Std.int(this.image.width / this.tilewidth);
    var tylen:Int = Std.int(this.image.height / this.tileheight);
    var rect:Array<Rectangle> = new Array<Rectangle>();
    for (ty in 0...tylen) {
      for (tx in 0...txlen) {
        rect.push(
          new Rectangle(
            tx * this.tilewidth + tx * this.spacing + this.margin,
            ty * this.tileheight + ty * this.spacing + this.margin,
            this.tilewidth,
            this.tileheight
          )
        );
      }
    }
    this.tileset = new openfl.display.Tileset(
      this.image.bitmap.bitmapData,
      rect
    );
    // fire complete event
    this.dispatchEvent(new Event(Event.COMPLETE));
  }
}
