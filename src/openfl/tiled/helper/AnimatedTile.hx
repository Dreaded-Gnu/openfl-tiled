package openfl.tiled.helper;

import openfl.events.Event;

class AnimatedTile extends openfl.display.Tile {
  public var animation(get, set):openfl.tiled.tileset.Animation;
  public var realX(default, default):Float;
  public var realY(default, default):Float;
  public var map(get, set):openfl.tiled.Map;

  private var mAnimation:openfl.tiled.tileset.Animation;
  private var mCurrentAnimation:Int;
  private var mMaxAnimation:Int;
  private var mMap:openfl.tiled.Map;
  private var mPreviousTime:Float;
  private var mDuration:Float;

  /**
   * Constructor
   * @param id
   * @param x
   * @param y
   * @param scaleX
   * @param scaleY
   * @param rotation
   * @param animation
   * @param map
   */
  public function new(id:Int, x:Float, y:Float, scaleX:Float, scaleY:Float, rotation:Float, animation:openfl.tiled.tileset.Animation, map:openfl.tiled.Map) {
    super(id, x, y, scaleX, scaleY, rotation);
    // save animation and prepare max animation
    this.mAnimation = animation;
    this.mMaxAnimation = animation != null ? animation.frame.length : 0;
    this.mMap = map;
    // save real x and y
    this.realX = this.x;
    this.realY = this.y;
    // set initial timer
    if (this.mAnimation != null && this.mAnimation.frame.length > 0) {
      // set current animation and id
      this.mCurrentAnimation = 0;
      this.id = this.mAnimation.frame[mCurrentAnimation].tileid;
      // previous time is now and duration is 0
      this.mPreviousTime = haxe.Timer.stamp();
      this.mDuration = 0;
      // Add enter frame listener
      this.mMap.tilemap.stage?.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
  }

  /**
   * Switch tile on animation delay completed on enter frame
   * @param event
   */
  private function onEnterFrame(event:Event):Void {
    // save current time
    var currentTime:Float = haxe.Timer.stamp();
    // calculate milliseconds delta
    var deltaTime:Float = Std.int((currentTime - this.mPreviousTime) * 1000);
    // update previous time
    this.mPreviousTime = currentTime;
    // increase duration
    this.mDuration += deltaTime;
    // handle frame not yet done
    if (this.mDuration < this.mAnimation.frame[mCurrentAnimation].duration) {
      return;
    }
    // reset duration time
    this.mDuration = 0;
    // handle max animation step reached
    if (++this.mCurrentAnimation >= this.mMaxAnimation) {
      this.mCurrentAnimation = 0;
    }
    // set id correctly
    id = this.mAnimation.frame[mCurrentAnimation].tileid;
    // get tileset by id
    var tileset:openfl.tiled.Tileset = this.mMap.tilesetByGid(id);
    // get tile of tileset by id
    var tile:openfl.tiled.tileset.Tile = tileset.getTileByGid(id);
    // overwrite tileset
    this.tileset = tileset.tileset;
    // overwrite tileset with one from tile if set
    if (tile?.tileset != null) {
      this.tileset = tile.tileset;
      // reset id to 0
      this.id = 0;
    }
  }

  /**
   * Animation setter
   * @param animation
   * @return openfl.tiled.tileset.Animation
   */
  private function set_animation(animation:openfl.tiled.tileset.Animation):openfl.tiled.tileset.Animation {
    this.mAnimation = animation;
    this.mMaxAnimation = animation != null ? animation.frame.length : 0;
    if (this.mCurrentAnimation >= this.mMaxAnimation) {
      this.mCurrentAnimation = 0;
    }
    return this.mAnimation;
  }

  /**
   * Animation getter
   * @return openfl.tiled.tileset.Animation
   */
  private function get_animation():openfl.tiled.tileset.Animation {
    return this.mAnimation;
  }

  /**
   * Map setter
   * @param map
   * @return openfl.tiled.Map
   */
  private function set_map(map:openfl.tiled.Map):openfl.tiled.Map {
    return this.mMap = map;
  }

  /**
   * Map getter
   * @return openfl.tiled.Map
   */
  private function get_map():openfl.tiled.Map {
    return this.mMap;
  }
}
