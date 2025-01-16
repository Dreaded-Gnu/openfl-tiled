package;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.display.FPS;
import openfl.events.Event;
import openfl.display.Sprite;
#if commonjs
import openfl.display.Stage;
#end

class Main extends Sprite {
  private var mMap:openfl.tiled.Map;
  private var mPlayer:openfl.display.Sprite;
  private var mKeys = [];
  private var mOffsetX:Int = 0;
  private var mOffsetY:Int = 0;

  private static inline var MOVE_SPEED:Int = 2;

  /**
   * Constructor
   */
  public function new() {
    super();
    // load map
    // this.mMap = new openfl.tiled.Map("phaser/tmx/", "phaser/tmx/features test.tmx");
    // this.mMap = new openfl.tiled.Map("phaser/tmx", "phaser/tmx/collision test.tmx");
    this.mMap = new openfl.tiled.Map("tiled/desert_infinite/", "tiled/desert_infinite/desert_infinite.tmx");
    // this.mMap = new openfl.tiled.Map("tiled/desert/", "tiled/desert/desert.tmx");
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
    // add as child
    this.addChild(this.mMap.tilemap);
    // create and add player
    this.mPlayer = new openfl.display.Sprite();
    this.mPlayer.graphics.beginFill(0xFFCC00);
    this.mPlayer.graphics.drawRect(0, 0, this.mMap.tilewidth - 1, this.mMap.tileheight - 1);
    this.mPlayer.x = this.mMap.tilewidth;
    this.mPlayer.y = this.mMap.tileheight;
    addChild(this.mPlayer);
    // add fps counter
    addChild(new FPS(10, 10, 0xffffff));
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
    var changeX:Bool = false;
    var changeY:Bool = false;
    var newOffsetX:Int = mOffsetX;
    var newOffsetY:Int = mOffsetY;
    var playerOffsetX:Int = Std.int(this.mPlayer?.x ?? 0);
    var playerOffsetY:Int = Std.int(this.mPlayer?.y ?? 0);
    if (mKeys[Keyboard.UP]) {
      changeY = true;
      newOffsetY = Std.int(Math.max(newOffsetY - MOVE_SPEED, 0));
      playerOffsetY = Std.int(Math.max(this.mPlayer.y - MOVE_SPEED, 0));
    } else if (mKeys[Keyboard.DOWN]) {
      changeY = true;
      if (this.mMap.height * this.mMap.tileheight > this.stage.stageHeight) {
        newOffsetY = Std.int(Math.min(newOffsetY + MOVE_SPEED, this.mMap.height * this.mMap.tileheight - this.stage.stageHeight));
      }
      playerOffsetY = Std.int(Math.min(this.mPlayer.y + MOVE_SPEED, this.stage.stageHeight - this.mPlayer.height));
    } else if (mKeys[Keyboard.LEFT]) {
      changeX = true;
      newOffsetX = Std.int(Math.max(newOffsetX - MOVE_SPEED, 0));
      playerOffsetX = Std.int(Math.max(this.mPlayer.x - MOVE_SPEED, 0));
    } else if (mKeys[Keyboard.RIGHT]) {
      changeX = true;
      if (this.mMap.width * this.mMap.tilewidth > this.stage.stageWidth) {
        newOffsetX = Std.int(Math.min(newOffsetX + MOVE_SPEED, this.mMap.width * this.mMap.tilewidth - this.stage.stageWidth));
      }
      playerOffsetX = Std.int(Math.min(this.mPlayer.x + MOVE_SPEED, this.stage.stageWidth - this.mPlayer.width));
    }
    if (this.mMap.isLoaded && (changeX || changeY)) {
      if (this.mPlayer != null) {
        var oldPlayerX:Float = Math.round(this.mPlayer.x);
        var oldPlayerY:Float = Math.round(this.mPlayer.y);
        this.mPlayer.x = playerOffsetX;
        this.mPlayer.y = playerOffsetY;
        if (this.mPlayer.x - this.mPlayer.width / 2 < this.stage.stageWidth / 2 - this.mPlayer.width / 2
          && mOffsetX > 0
          && mOffsetX < this.mMap.width * this.mMap.tilewidth - this.stage.stageWidth
          && changeX) {
          this.mPlayer.x = this.stage.stageWidth / 2 - this.mPlayer.width / 2;
        }
        if (this.mPlayer.y - this.mPlayer.height / 2 < this.stage.stageHeight / 2 - this.mPlayer.height / 2
          && mOffsetY > 0
          && mOffsetY < this.mMap.height * this.mMap.tileheight - this.stage.stageHeight
          && changeY) {
          this.mPlayer.y = this.stage.stageHeight / 2 - this.mPlayer.height / 2;
        }
        // check for collision
        if (this.mMap.collides(Std.int(this.mPlayer.x), Std.int(this.mPlayer.y), Std.int(this.mPlayer.width), Std.int(this.mPlayer.height))) {
          this.mPlayer.x = oldPlayerX;
          this.mPlayer.y = oldPlayerY;
          changeX = changeY = false;
        }
      }
      if ((this.mPlayer.x + this.mPlayer.width / 2 >= this.stage.stageWidth / 2 - this.mPlayer.width / 2
        && mOffsetX < this.mMap.width * this.mMap.tilewidth - this.stage.stageWidth
        && changeX)
        || (this.mPlayer.x + this.mPlayer.width / 2 < this.stage.stageWidth / 2 - this.mPlayer.width / 2
          && mOffsetX >= this.mMap.width * this.mMap.tilewidth - this.stage.stageWidth
          && changeX)
        || (this.mPlayer.y + this.mPlayer.height / 2 >= this.stage.stageHeight / 2 - this.mPlayer.height / 2
          && mOffsetY < this.mMap.height * this.mMap.tileheight - this.stage.stageHeight
          && changeY)
        || (this.mPlayer.y + this.mPlayer.height / 2 < this.stage.stageHeight / 2 - this.mPlayer.height / 2
          && mOffsetY >= this.mMap.height * this.mMap.tileheight - this.stage.stageHeight
          && changeY)) {
        if (this.mPlayer.x + this.mPlayer.width / 2 < this.stage.stageWidth / 2 - this.mPlayer.width / 2
          && mOffsetX >= this.mMap.width * this.mMap.tilewidth - this.stage.stageWidth
          && this.mMap.width * this.mMap.tilewidth > this.stage.stageWidth
          && changeX) {
          this.mPlayer.x = this.stage.stageWidth / 2 - this.mPlayer.width / 2;
        }
        if (this.mPlayer.y + this.mPlayer.height / 2 < this.stage.stageHeight / 2 - this.mPlayer.height / 2
          && mOffsetY >= this.mMap.height * this.mMap.tileheight - this.stage.stageHeight
          && this.mMap.height * this.mMap.tileheight > this.stage.stageHeight
          && changeY) {
          this.mPlayer.y = this.stage.stageHeight / 2 - this.mPlayer.height / 2;
        }
        mOffsetX = newOffsetX;
        mOffsetY = newOffsetY;
        this.mMap.render(mOffsetX, mOffsetY);
      }
    }
  }

  #if commonjs
  /**
   * main function
   */
  public static function main():Void {
    var stage:Stage = new Stage(640, 480, 0x000000, Main);
    js.Browser.document.body.appendChild(stage.element);
  }
  #end
}
