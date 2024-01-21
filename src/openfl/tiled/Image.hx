package openfl.tiled;

import openfl.display.Bitmap;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.net.URLRequest;
import openfl.net.URLLoader;
import openfl.events.EventDispatcher;

class Image extends EventDispatcher {
  public var format(default, null):String;
  public var source(default, null):String;
  public var trans(default, null):UInt;
  public var width(default, null):Int;
  public var height(default, null):Int;
  public var data(default, null):openfl.tiled.layer.Data;

  public var bitmap(default, null):Bitmap;

  public function new(node:Xml) {
    // call parent constructor
    super();
    // parse stuff
    this.format = node.get("format");
    this.source = node.get("source");
    this.trans = node.exists("trans")
      ? Std.parseInt("0xFF" + node.get("trans"))
      : 0x00000000;
    this.width = Std.parseInt(node.get("width"));
    this.height = Std.parseInt(node.get("height"));
  }

  /**
   * Load method
   */
  public function load():Void {
    // load image asynchronously
    var request:URLRequest = new URLRequest(this.source);
    var loader:Loader = new Loader();
    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
    loader.load(request);
  }

  /**
   * On load complete event
   * @param event
   */
  private function onLoadComplete(event:Event) {
    // get loader
    var loader:Loader = cast(event.target.loader, Loader);
    // unregister complete handler
    loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
    // save graphics
    bitmap = cast(loader.content, Bitmap);
    // dispatch loaded event
    this.dispatchEvent(new Event(Event.COMPLETE));
  }
}
