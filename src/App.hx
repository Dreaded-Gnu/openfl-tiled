import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.display.FPS;
import openfl.events.Event;
import openfl.display.Sprite;
import openfl.display.Stage;

class App extends Sprite {
  private var mMap:openfl.tiled.Map;
  private var mRenderedMap:Sprite = null;
  private var mKeys = [];
  private var mOffsetX:Int = 0;
  private var mOffsetY:Int = 0;

  /**
   * Constructor
   */
  public function new() {
    super();
    // load map
    this.mMap = new openfl.tiled.Map("/sewers.tmx");
    // set complete event listener
    this.mMap.addEventListener(Event.COMPLETE, onMapLoadComplete);
    // set event listener
    this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
    this.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    // kickstart map loading
    this.mMap.load();
  }

  /**
   * Method to switch map renderer
   * @param sprite
   */
  private function switchMapRender(sprite:Sprite):Void {
    if (mRenderedMap != null) {
      removeChild(mRenderedMap);
    }
    mRenderedMap = sprite;
    addChild(mRenderedMap);
  }

  /**
   * On map load completed
   * @param event
   */
  private function onMapLoadComplete(event:Event):Void {
    this.mMap.removeEventListener(Event.COMPLETE, onMapLoadComplete);
    trace(this.mMap);
    this.switchMapRender(this.mMap.render());
  }

  /**
   * On key down handler
   * @param event
   */
  private function onKeyDown(event:KeyboardEvent):Void {
    mKeys[event.keyCode] = true;
  }

  /**
   * On key up handler
   * @param event
   */
  private function onKeyUp(event:KeyboardEvent):Void {
    mKeys[event.keyCode] = false;
  }

  private function onEnterFrame(event:Event):Void {
    var change:Bool = false;
    if (mKeys[Keyboard.UP]) {
      change = true;
      mOffsetX += 10;
    } else if (mKeys[Keyboard.DOWN]) {
      change = true;
      mOffsetX -= 10;
    } else if (mKeys[Keyboard.LEFT]) {
      change = true;
      mOffsetY += 10;
    } else if (mKeys[Keyboard.RIGHT]) {
      change = true;
      mOffsetY -= 10;
    }
    if (this.mMap.isLoaded && change) {
      trace(mOffsetX, mOffsetY);
      this.switchMapRender(this.mMap.render(mOffsetX, mOffsetY));
    }
  }

  /**
   * main function
   */
  public static function main():Void {
    var stage = new Stage(800, 600, 0x000000, App);
    stage.addChild(new FPS(10, 10, 0xffffff));
    js.Browser.document.body.appendChild(stage.element);
  }
}