package;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.display.FPS;
import openfl.events.Event;
import openfl.display.Sprite;
import openfl.display.Stage;

class Main extends Sprite {
  private var mMap:openfl.tiled.Map;
  private var mTilemap:openfl.display.Tilemap;
  private var mPlayer:openfl.display.Sprite;
  private var mKeys = [];
  private var mOffsetX:Int = 0;
  private var mOffsetY:Int = 0;

  /**
   * Constructor
   */
  public function new() {
    super();
    // tilemap
    this.mTilemap = new openfl.display.Tilemap(stage.stageWidth, stage.stageHeight);
    addChild(this.mTilemap);
    // add fps counter
    addChild(new FPS(10, 10, 0xffffff));
    // load map
    this.mMap = new openfl.tiled.Map("/phaser/tmx/", "/phaser/tmx/collision test.tmx", this.mTilemap);
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
   * On map load completed
   * @param event
   */
  private function onMapLoadComplete(event:Event):Void {
    this.mMap.removeEventListener(Event.COMPLETE, onMapLoadComplete);
    // render map
    this.mMap.render();
    // create and add player
    this.mPlayer = new openfl.display.Sprite();
    this.mPlayer.graphics.beginFill(0xFFCC00);
    this.mPlayer.graphics.drawRect(0, 0, this.mMap.tilewidth - 1, this.mMap.tileheight - 1);
    this.mPlayer.x = this.mMap.tilewidth;
    this.mPlayer.y = this.mMap.tileheight;
    addChild(this.mPlayer);
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

  /**
   * On frame enter
   * @param event
   */
  private function onEnterFrame(event:Event):Void {
    var change:Bool = false;
    var previousOffsetX:Int = mOffsetX;
    var previousOffsetY:Int = mOffsetY;
    var playerOffsetX:Int = 0;
    var playerOffsetY:Int = 0;
    if (mKeys[Keyboard.UP]) {
      change = true;
      mOffsetY = Std.int(Math.max(mOffsetY - 10, 0));
      playerOffsetY -= 1;
    } else if (mKeys[Keyboard.DOWN]) {
      change = true;
      mOffsetY = Std.int(Math.min(mOffsetY + 10, this.mMap.height * this.mMap.tileheight - this.stage.stageHeight));
      playerOffsetY += 1;
    } else if (mKeys[Keyboard.LEFT]) {
      change = true;
      mOffsetX = Std.int(Math.max(mOffsetX - 10, 0));
      playerOffsetX -= 1;
    } else if (mKeys[Keyboard.RIGHT]) {
      change = true;
      mOffsetX = Std.int(Math.min(mOffsetX + 10, this.mMap.width * this.mMap.tilewidth - this.stage.stageWidth));
      playerOffsetX += 1;
    }
    if (this.mMap.isLoaded && change) {
      if (this.mPlayer != null) {
        this.mPlayer.x += playerOffsetX;
        this.mPlayer.y += playerOffsetY;
        if (this.mMap.collides(Std.int(this.mPlayer.x), Std.int(this.mPlayer.y), Std.int(this.mPlayer.width), Std.int(this.mPlayer.height))) {
          this.mPlayer.x -= playerOffsetX;
          this.mPlayer.y -= playerOffsetY;
        }
      }
      // this.mMap.render(mOffsetX, mOffsetY, previousOffsetX, previousOffsetY);
    }
  }

  #if commonjs
  /**
   * main function
   */
  public static function main():Void {
    var stage:Stage = new Stage(1024, 768, 0x000000, Main);
    js.Browser.document.body.appendChild(stage.element);
  }
  #end
}
