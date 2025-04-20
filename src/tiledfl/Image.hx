package tiledfl;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.geom.Point;

/**
 * Image representation
 */
class Image extends EventDispatcher {
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
  public var width(default, null):Int;

  /**
   * Height
   */
  public var height(default, null):Int;

  /**
   * Possible embedded data
   */
  public var data(default, null):tiledfl.image.Data;

  /**
   * Loaded bitmap
   */
  public var bitmap(default, null):Bitmap;

  private var mTransSet:Bool;
  private var mMap:tiledfl.Map;

  /**
   * Constructor
   * @param node
   * @param map
   */
  public function new(node:Xml, map:tiledfl.Map) {
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
    for (child in node) {
      // skip non elements
      if (child.nodeType != Xml.Element) {
        continue;
      }
      // handle child
      switch (child.nodeName) {
        case "data":
          this.data = new tiledfl.image.Data(child);
      }
    }
  }

  /**
   * Load method
   */
  @:dox(hide) @:noCompletion public function load():Void {
    // handle data set
    if (this.data != null) {
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
    #if TiledFL_use_asset
    onLoadComplete(Assets.getBitmapData(Helper.joinPath(this.mMap.prefix, this.source)));
    #else
    BitmapData.loadFromFile(Helper.joinPath(this.mMap.prefix, this.source)).onComplete(onLoadComplete);
    #end
  }

  /**
   * On load complete event
   * @param event
   */
  private function onLoadComplete(bitmapData:BitmapData) {
    // apply transparency if necessary
    if (this.mTransSet) {
      // manipulate pixel once trans property is set
      bitmapData.threshold(bitmapData, bitmapData.rect, new Point(0, 0), "==", this.trans);
    }
    // create bitmap
    bitmap = new Bitmap(bitmapData);
    // populate width and height if undefined
    if (-1 == this.width) {
      this.width = Std.int(bitmap.width);
    }
    if (-1 == this.height) {
      this.height = Std.int(bitmap.height);
    }
    // dispatch load complete
    this.dispatchEvent(new Event(Event.COMPLETE));
  }
}
