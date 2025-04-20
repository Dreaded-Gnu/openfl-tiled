package tiledfl.helper;

import openfl.events.Event;

/**
 * Animated tile implementation extending openfl.display.Tile
 */
class AnimatedTile extends openfl.display.Tile {
  /**
   * Animation data used for this tile
   */
  public var animation(get, set):tiledfl.tileset.Animation;

  /**
   * Real x value which might differ to x because of possible tile flipping
   */
  public var realX(default, default):Float;

  /**
   * Real y value which might differ to y because of possible tile flipping
   */
  public var realY(default, default):Float;

  /**
   * Map this animated tile belongs to
   */
  public var map(get, set):tiledfl.Map;

  private var mAnimation:tiledfl.tileset.Animation;
  private var mCurrentAnimation:Int;
  private var mMaxAnimation:Int;
  private var mMap:tiledfl.Map;
  private var mPreviousTime:Float;
  private var mDuration:Float;

  /**
   * Constructor
   * @param id tile id
   * @param x x position
   * @param y y position
   * @param scaleX scale x
   * @param scaleY scale y
   * @param rotation rotation
   * @param animation animation data
   * @param map map instance
   */
  public function new(id:Int, x:Float, y:Float, scaleX:Float, scaleY:Float, rotation:Float, animation:tiledfl.tileset.Animation, map:tiledfl.Map) {
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
    var tileset:tiledfl.Tileset = this.mMap.tilesetByGid(id);
    // get tile of tileset by id
    var tile:tiledfl.tileset.Tile = tileset.getTileByGid(id);
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
   * @return tiledfl.tileset.Animation
   */
  private function set_animation(animation:tiledfl.tileset.Animation):tiledfl.tileset.Animation {
    this.mAnimation = animation;
    this.mMaxAnimation = animation != null ? animation.frame.length : 0;
    if (this.mCurrentAnimation >= this.mMaxAnimation) {
      this.mCurrentAnimation = 0;
    }
    return this.mAnimation;
  }

  /**
   * Animation getter
   * @return tiledfl.tileset.Animation
   */
  private function get_animation():tiledfl.tileset.Animation {
    return this.mAnimation;
  }

  /**
   * Map setter
   * @param map
   * @return tiledfl.Map
   */
  private function set_map(map:tiledfl.Map):tiledfl.Map {
    return this.mMap = map;
  }

  /**
   * Map getter
   * @return tiledfl.Map
   */
  private function get_map():tiledfl.Map {
    return this.mMap;
  }
}
