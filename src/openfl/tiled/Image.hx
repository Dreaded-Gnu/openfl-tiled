package openfl.tiled;

import openfl.errors.Error;
import openfl.geom.Point;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.events.EventDispatcher;

class Image extends EventDispatcher {
  public var format(default, null):String;
  public var source(default, null):String;
  public var trans(default, null):UInt;
  public var width(default, null):Int;
  public var height(default, null):Int;
  public var data(default, null):openfl.tiled.image.Data;

  public var bitmap(default, null):Bitmap;

  private var mTransSet:Bool;
  private var mMap:openfl.tiled.Map;

  /**
   * Constructor
   * @param node
   * @param map
   */
  public function new(node:Xml, map:openfl.tiled.Map) {
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
          this.data = new openfl.tiled.image.Data(child);
      }
    }
  }

  /**
   * Load method
   */
  public function load():Void {
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
    #if openfl_tiled_use_asset
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
