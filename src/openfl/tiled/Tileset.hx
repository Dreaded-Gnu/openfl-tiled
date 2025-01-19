package openfl.tiled;

import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Rectangle;
import openfl.net.URLRequest;
import openfl.net.URLLoader;
import openfl.tiled.map.Orientation;
import openfl.tiled.tileset.FillMode;
import openfl.tiled.tileset.TileRenderSize;
import openfl.tiled.tileset.ObjectAlignment;

/**
 * Tileset representation
 */
class Tileset extends EventDispatcher {
  /**
   * First gid
   */
  public var firstgid(default, null):Int;

  /**
   * Source to be loaded
   */
  public var source(default, null):String;

  /**
   * Name
   */
  public var name(default, null):String;

  /**
   * Class
   */
  public var klass(default, null):String;

  /**
   * Tile width
   */
  public var tilewidth(default, null):Int;

  /**
   * Tile height
   */
  public var tileheight(default, null):Int;

  /**
   * Spacing
   */
  public var spacing(default, null):Int;

  /**
   * Margin
   */
  public var margin(default, null):Int;

  /**
   * Tile count
   */
  public var tilecount(default, null):Int;

  /**
   * Columns
   */
  public var columns(default, null):Int;

  /**
   * Object alignment
   */
  public var objectalignment(default, null):ObjectAlignment;

  /**
   * Tile render size
   */
  public var tilerendersize(default, null):TileRenderSize;

  /**
   * Fill mode
   */
  public var fillmode(default, null):FillMode;

  /**
   * Tileset image
   */
  public var image(default, null):openfl.tiled.Image;

  /**
   * Tileset offset
   */
  public var tileoffset(default, null):openfl.tiled.tileset.TileOffset;

  /**
   * Grid
   */
  public var grid(default, null):openfl.tiled.tileset.Grid;

  /**
   * Properties
   */
  public var properties(default, null):openfl.tiled.Properties;

  /**
   * Terrain types
   */
  public var terraintypes(default, null):openfl.tiled.tileset.TerrainTypes;

  /**
   * Wangset
   */
  public var wangset(default, null):openfl.tiled.tileset.Wangsets;

  /**
   * Transformations
   */
  public var transformations(default, null):openfl.tiled.tileset.Transformations;

  /**
   * Map of tiles
   */
  public var tile(default, null):std.Map<Int, openfl.tiled.tileset.Tile>;

  /**
   * Openfl tileset created
   */
  public var tileset(default, null):openfl.display.Tileset;

  private var mSourceLoaded:Bool = false;
  private var mTileLoaded:Bool = false;
  private var mMap:openfl.tiled.Map;

  /**
   * Constructor
   * @param node xml representation to parse
   * @param map map the tileset belongs to
   */
  public function new(node:Xml, map:openfl.tiled.Map) {
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
    this.firstgid = node.exists("firstgid") ? Std.parseInt(node.get("firstgid")) : this.firstgid;
    this.source = node.exists("source") ? node.get("source") : this.source;
    this.name = node.get("name");
    this.klass = node.exists("class") ? node.get("class") : "";
    this.tilewidth = Std.parseInt(node.get("tilewidth"));
    this.tileheight = Std.parseInt(node.get("tileheight"));
    this.spacing = node.exists("spacing") ? Std.parseInt(node.get("spacing")) : 0;
    this.margin = node.exists("margin") ? Std.parseInt(node.get("margin")) : 0;
    this.tilecount = node.exists("tilecount") ? Std.parseInt(node.get("tilecount")) : -1;
    this.columns = node.exists("columns") ? Std.parseInt(node.get("columns")) : -1;
    var o:String = node.get("objectalignment");
    switch (o) {
      case "unspecified":
        this.objectalignment = this.mMap.orientation == Orientation.MapOrientationOrthogonal ? ObjectAlignment.TilesetObjectAlignmentBottomLeft : ObjectAlignment.TilesetObjectAlignmentBottom;
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
        this.objectalignment = this.mMap.orientation == Orientation.MapOrientationOrthogonal ? ObjectAlignment.TilesetObjectAlignmentBottomLeft : ObjectAlignment.TilesetObjectAlignmentBottom;
    }
    var tr:String = node.exists("tilerendersize") ? node.get("tilerendersize") : "tile";
    switch (tr) {
      case "tile":
        this.tilerendersize = TileRenderSize.TilesetTileRenderSizeTile;
      case "grid":
        this.tilerendersize = TileRenderSize.TilesetTileRenderSizeGrid;
    }
    var fm:String = node.exists("fillmode") ? node.get("fillmode") : "stretch";
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
          this.tile.set(Std.parseInt(child.get("id")), new openfl.tiled.tileset.Tile(child, this.mMap));
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
  @:dox(hide) @:noCompletion public function getTileByGid(gid:Int):openfl.tiled.tileset.Tile {
    for (tile in this.tile) {
      if (tile.id == gid) {
        return tile;
      }
    }
    return null;
  }

  /**
   * Load callback
   */
  @:dox(hide) @:noCompletion public function load():Void {
    if (!this.mSourceLoaded && this.source != null) {
      #if TiledFL_use_asset
      var data:String = Assets.getText(Helper.joinPath(this.mMap.prefix, this.source));
      // parse xml
      this.parse(Xml.parse(data).firstElement());
      // set loaded to true
      this.mSourceLoaded = true;
      // continue loading
      this.load();
      #else
      var request:URLRequest = new URLRequest(Helper.joinPath(this.mMap.prefix, this.source));
      var loader:URLLoader = new URLLoader();
      // set load complete callback
      loader.addEventListener(Event.COMPLETE, (event:Event) -> {
        // parse xml
        this.parse(Xml.parse(loader.data).firstElement());
        // set loaded to true
        this.mSourceLoaded = true;
        // continue loading
        this.load();
      });
      loader.load(request);
      #end
    } else if (!this.mTileLoaded) {
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
        tile.addEventListener(Event.COMPLETE, (event:Event) -> {
          tmpTile.remove(tile);
          // continue loading when end was reached
          if (0 >= tmpTile.length) {
            // set tile loaded flag
            this.mTileLoaded = true;
            // continue with load process
            this.load();
          }
        });
        // load tile
        tile.load();
      }
    } else if (this.image != null && this.tileset == null) {
      // set complete handler
      this.image.addEventListener(Event.COMPLETE, onImageCompleted);
      // load image
      this.image.load();
    } else {
      // dispatch complete event
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
    // evaluate tx and ty length
    var txlen:Int = Std.int(this.image.width / this.tilewidth);
    var tylen:Int = Std.int(this.image.height / this.tileheight);
    // prepare tileset rectangles
    var rect:Array<Rectangle> = new Array<Rectangle>();
    for (ty in 0...tylen) {
      for (tx in 0...txlen) {
        rect.push(new Rectangle(tx * this.tilewidth + tx * this.spacing + this.margin, ty * this.tileheight + ty * this.spacing + this.margin, this.tilewidth,
          this.tileheight));
      }
    }
    // generate tileset
    this.tileset = new openfl.display.Tileset(this.image.bitmap.bitmapData, rect);
    // call load again to continue
    this.load();
  }
}
