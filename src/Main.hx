package;

import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

class Main extends Sprite {
  private var mMap:tiledfl.Map;
  private var mPlayer:Sprite;
  private var mKeys:Map<Int, Bool> = [];
  private var mOffsetX:Int = 0;
  private var mOffsetY:Int = 0;

  private static inline var SCALE:Float = 2;
  private static inline var MOVE_SPEED:Float = 2;

  /**
   * Constructor
   */
  public function new() {
    super();
    // load map
    // this.mMap = new tiledfl.Map("phaser/tmx/", "phaser/tmx/features test.tmx", this.stage.stageWidth, this.stage.stageHeight);
    // this.mMap = new tiledfl.Map("tiled/rpg/", "tiled/rpg/island.tmx", this.stage.stageWidth, this.stage.stageHeight);
    // this.mMap = new tiledfl.Map("phaser/tmx", "phaser/tmx/collision test.tmx", this.stage.stageWidth, this.stage.stageHeight);
    this.mMap = new tiledfl.Map("tiled/desert_infinite/", "tiled/desert_infinite/desert_infinite.tmx", this.stage.stageWidth, this.stage.stageHeight);
    this.mMap.tilemap.scaleX = SCALE;
    this.mMap.tilemap.scaleY = SCALE;
    // this.mMap = new tiledfl.Map("tiled/desert/", "tiled/desert/desert.tmx", this.stage.stageWidth, this.stage.stageHeight);
    // set complete event listener
    this.mMap.addEventListener(Event.COMPLETE, onMapLoadComplete);
    // set event listener
    this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
    this.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    this.stage.addEventListener(Event.RESIZE, this.onResize);
    // kickstart map loading
    this.mMap.load();
  }

  /**
   * Resize event handler
   * @param event
   */
  private function onResize(event:Event):Void {
    this.mMap.resize(this.stage.stageWidth, this.stage.stageHeight);
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
    this.mPlayer = new Sprite();
    this.mPlayer.graphics.beginFill(0xFFCC00);
    this.mPlayer.graphics.drawRect(0, 0, this.mMap.tilewidth - 1, this.mMap.tileheight - 1);
    this.mPlayer.x = this.mMap.tilewidth * SCALE;
    this.mPlayer.y = this.mMap.tileheight * SCALE;
    this.mPlayer.scaleX = SCALE;
    this.mPlayer.scaleY = SCALE;
    addChild(this.mPlayer);
    // create fps counter
    var fps:FPS = new FPS(10 * SCALE, 10 * SCALE);
    // apply scale
    fps.scaleX = SCALE;
    fps.scaleY = SCALE;
    // add as child
    addChild(fps);
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
    // calculate map height and width
    var mapHeight:Int = Std.int(this.mMap.height * this.mMap.tileheight * SCALE);
    var mapWidth:Int = Std.int(this.mMap.width * this.mMap.tilewidth * SCALE);
    // handle keys
    if (mKeys[Keyboard.UP]) {
      changeY = true;
      newOffsetY = Std.int(Math.max(newOffsetY - MOVE_SPEED, 0));
      playerOffsetY = Std.int(Math.max(this.mPlayer.y - MOVE_SPEED, 0));
    } else if (mKeys[Keyboard.DOWN]) {
      changeY = true;
      if (mapHeight > this.stage.stageHeight) {
        newOffsetY = Std.int(Math.min(newOffsetY + MOVE_SPEED, mapHeight * SCALE - this.stage.stageHeight));
      }
      playerOffsetY = Std.int(Math.min(this.mPlayer.y + MOVE_SPEED, this.stage.stageHeight - this.mPlayer.height));
    } else if (mKeys[Keyboard.LEFT]) {
      changeX = true;
      newOffsetX = Std.int(Math.max(newOffsetX - MOVE_SPEED, 0));
      playerOffsetX = Std.int(Math.max(this.mPlayer.x - MOVE_SPEED, 0));
    } else if (mKeys[Keyboard.RIGHT]) {
      changeX = true;
      if (mapWidth > this.stage.stageWidth) {
        newOffsetX = Std.int(Math.min(newOffsetX + MOVE_SPEED, mapWidth - this.stage.stageWidth));
      }
      playerOffsetX = Std.int(Math.min(this.mPlayer.x + MOVE_SPEED, this.stage.stageWidth - this.mPlayer.width));
    }
    // handle map rendering
    if (this.mMap.isLoaded && (changeX || changeY)) {
      if (this.mPlayer != null) {
        var oldPlayerX:Float = this.mPlayer.x;
        var oldPlayerY:Float = this.mPlayer.y;
        this.mPlayer.x = playerOffsetX;
        this.mPlayer.y = playerOffsetY;
        // check for collision
        if (this.mMap.collides(Std.int(this.mPlayer.x / SCALE), Std.int(this.mPlayer.y / SCALE), this.mMap.tilewidth, this.mMap.tileheight)) {
          this.mPlayer.x = oldPlayerX;
          this.mPlayer.y = oldPlayerY;
          changeX = changeY = false;
        }
        // check for center map
        if (this.mPlayer.x - this.mPlayer.width / 2 < this.stage.stageWidth / 2 - this.mPlayer.width / 2
          && mOffsetX * SCALE > 0
          && mOffsetX * SCALE < mapWidth - this.stage.stageWidth
          && changeX) {
          this.mPlayer.x = this.stage.stageWidth / 2 - this.mPlayer.width / 2;
        }
        if (this.mPlayer.y - this.mPlayer.height / 2 < this.stage.stageHeight / 2 - this.mPlayer.height / 2
          && mOffsetY * SCALE > 0
          && mOffsetY * SCALE < mapHeight - this.stage.stageHeight
          && changeY) {
          this.mPlayer.y = this.stage.stageHeight / 2 - this.mPlayer.height / 2;
        }
      }
      if ((this.mPlayer.x + this.mPlayer.width / 2 >= this.stage.stageWidth / 2 - this.mPlayer.width / 2
        && mOffsetX * SCALE < mapWidth - this.stage.stageWidth
        && changeX)
        || (this.mPlayer.x + this.mPlayer.width / 2 < this.stage.stageWidth / 2 - this.mPlayer.width / 2
          && mOffsetX * SCALE >= mapWidth - this.stage.stageWidth
          && changeX)
        || (this.mPlayer.y + this.mPlayer.height / 2 >= this.stage.stageHeight / 2 - this.mPlayer.height / 2
          && mOffsetY * SCALE < mapHeight - this.stage.stageHeight
          && changeY)
        || (this.mPlayer.y + this.mPlayer.height / 2 < this.stage.stageHeight / 2 - this.mPlayer.height / 2
          && mOffsetY * SCALE >= mapHeight - this.stage.stageHeight
          && changeY)) {
        if (this.mPlayer.x + this.mPlayer.width / 2 < this.stage.stageWidth / 2 - this.mPlayer.width / 2
          && mOffsetX * SCALE >= mapWidth - this.stage.stageWidth
          && mapWidth > this.stage.stageWidth
          && changeX) {
          this.mPlayer.x = this.stage.stageWidth / 2 - this.mPlayer.width / 2;
        }
        if (this.mPlayer.y + this.mPlayer.height / 2 < this.stage.stageHeight / 2 - this.mPlayer.height / 2
          && mOffsetY * SCALE >= mapHeight - this.stage.stageHeight
          && mapHeight > this.stage.stageHeight
          && changeY) {
          this.mPlayer.y = this.stage.stageHeight / 2 - this.mPlayer.height / 2;
        }
        mOffsetX = newOffsetX;
        mOffsetY = newOffsetY;
        this.mMap.render(mOffsetX, mOffsetY);
      }
    }
  }
}
