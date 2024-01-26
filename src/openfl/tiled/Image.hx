package openfl.tiled;

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
  public var data(default, null):openfl.tiled.layer.Data;

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
    this.width = Std.parseInt(node.get("width"));
    this.height = Std.parseInt(node.get("height"));
  }

  /**
   * Load method
   */
  public function load():Void {
    BitmapData.loadFromFile(Helper.joinPath(this.mMap.prefix, this.source)).onComplete(onLoadComplete);
  }

  /**
   * On load complete event
   * @param event
   */
  private function onLoadComplete(bitmapData:BitmapData) {
    if (this.mTransSet) {
      // manipulate pixel once trans property is set
      bitmapData.threshold(bitmapData, bitmapData.rect, new Point(0, 0), "==", this.trans);
    }
    // create bitmap
    bitmap = new Bitmap(bitmapData);
    // dispatch load complete
    this.dispatchEvent(new Event(Event.COMPLETE));
  }
}
