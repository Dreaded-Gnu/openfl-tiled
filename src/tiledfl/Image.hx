package tiledfl;

#if tiledfl_use_asset
import openfl.Assets;
#end
import openfl.display.BitmapData;
import openfl.display.Bitmap;
#if (js && html5)
import openfl.errors.Error;
#end
import openfl.events.Event;
import openfl.geom.Point;
import tiledfl.image.Data;

/**
 * Image representation
 *
 * @event complete Dispatched once image layer loading is completed
 */
@:allow(tiledfl.ImageLayer)
@:allow(tiledfl.TMap)
@:allow(tiledfl.Tileset)
@:allow(tiledfl.tileset.Tile)
class Image extends RootObject
{
  /**
   * Format
   */
  public var format(default, null):String;

  /**
   * Source image
   */
  public var source(default, null):String;

  /**
   * Transparent color
   */
  public var trans(default, null):UInt;

  /**
   * Width
   */
  public var width(default, null):Float;

  /**
   * Height
   */
  public var height(default, null):Float;

  /**
   * Possible embedded data
   */
  public var data(default, null):Data;

  /**
   * Loaded bitmap
   */
  public var bitmap(default, null):Bitmap;

  private var mTransSet:Bool;
  private var mMap:TMap;

  /**
   * Constructor
   * @param node representation to parse
   * @param map map object this new instance belongs to
   */
  public function new(node:Xml, map:TMap)
  {
    super();
    // cache map
    this.mMap = map;
    // parse stuff
    this.format = node.get("format");
    this.source = node.get("source");
    this.trans = node.exists("trans") ? Std.parseInt("0xFF" + node.get("trans")) : 0x00000000;
    this.mTransSet = node.exists("trans");
    this.width = node.exists("width") ? Std.parseInt(node.get("width")) : -1;
    this.height = node.exists("height") ? Std.parseInt(node.get("height")) : -1;
    // parse children
    for (child in node)
    {
      // skip non elements
      if (child.nodeType != Xml.Element)
      {
        continue;
      }
      // handle child
      switch (child.nodeName)
      {
        case "data":
          this.data = new Data(child);
      }
    }
  }

  /**
   * Load method
   */
  private function load():Void
  {
    if (this.isDisposed())
    {
      return;
    }
    // handle data set
    if (this.data != null)
    {
      // emit warning for not supported targets
      #if (js && html5)
      throw new Error("Embedded images are not supported in js html5 target!");
      #end
      // call on complete with BitmapData.fromBytes result
      this.onLoadComplete(BitmapData.fromBytes(this.data.data));
      // skip loading
      return;
    }
    // load from file
    #if tiledfl_use_asset
    onLoadComplete(Assets.getBitmapData(Helper.joinPath(this.mMap.prefix, this.source)));
    #else
    BitmapData.loadFromFile(Helper.joinPath(this.mMap.prefix, this.source)).onComplete(onLoadComplete);
    #end
  }

  /**
   * On load complete event
   * @param event
   */
  private function onLoadComplete(bitmapData:BitmapData)
  {
    if (this.isDisposed())
    {
      return;
    }
    // apply transparency if necessary
    if (this.mTransSet)
    {
      // manipulate pixel once trans property is set
      bitmapData.threshold(bitmapData, bitmapData.rect, new Point(0, 0), "==", this.trans);
    }
    // create bitmap
    this.bitmap = new Bitmap(bitmapData);
    // populate width and height if undefined
    if (-1 == this.width)
    {
      this.width = bitmap.width;
    }
    if (-1 == this.height)
    {
      this.height = bitmap.height;
    }
    // dispatch load complete
    this.dispatchEvent(new Event(Event.COMPLETE));
  }

  /**
   * Dispose method
   */
  override public function dispose():Void
  {
    super.dispose();
    this.data?.dispose();
    this.data = null;
    this.mMap = null;
    this.bitmap = null;
  }
}
