package tiledfl;

import haxe.Int64;
import haxe.io.Path;
import openfl.utils.ByteArray;

/**
 * Class with some helpers
 */
class Helper {
  private static inline var GID_ROTATED_HEXAGONAL_120_FLAG:UInt = 0x10000000;
  private static inline var GID_FLIPPED_DIAGONALLY_FLAG:UInt = 0x20000000;
  private static inline var GID_FLIPPED_VERTICALLY_FLAG:UInt = 0x40000000;
  private static inline var GID_FLIPPED_HORIZONTALLY_FLAG:UInt = 0x80000000;

  /**
   * Name a layer has to have when wanting to be considered for collision
   */
  public static inline var COLLISION_LAYER_NAME:String = "collision";

  /**
   * Collision property type to be set when wanting to be considered for collision
   */
  public static inline var COLLISION_PROPERTY_NAME:String = "collides";

  /**
   * Helper to convert base64 to openfl byte array
   * @param data base64 data string to convert to byte array
   * @return ByteArray
   */
  public static function base64ToByteArray(data:String):ByteArray {
    // replace newlines and spaces as they are invalid
    data = ~/\s/g.replace(data, '');
    // decode using haxe crypto
    var bytes:haxe.io.Bytes = haxe.crypto.Base64.decode(data);
    // return byte array from bytes
    return ByteArray.fromBytes(bytes);
  }

  /**
   * Helper to convert csv data to array of integer
   * @param input csv input data to convert to array of integer
   * @return Array of integer
   */
  public static function csvToArray(input:String):Array<Int> {
    var result:Array<Int> = new Array<Int>();
    // split rows by newline
    var rows:Array<String> = StringTools.trim(input).split("\n");
    // iterate through rows
    for (row in rows) {
      if ("" == row) {
        // skip empty rows
        continue;
      }
      // split row by comma to get entries
      var entries:Array<String> = row.split(",");
      // loop through entries
      for (entry in entries) {
        if ("" == entry) {
          // skip empty strings
          continue;
        }
        // push back tile
        result.push(Std.parseInt(entry));
      }
    }
    return result;
  }

  /**
   * Helper to join two path parts
   * @param path1 first part of path to join
   * @param path2 second part of path to join
   * @return Joined path
   */
  public static function joinPath(path1:String, path2:String):String {
    return Path.normalize(Path.join([path1 ?? "", path2 ?? "",]));
  }

  /**
   * Helper to extract gid
   * @param gid gid to extract
   * @return gid without flipping or rotation flags
   */
  public static function extractGid(gid:Int):Int {
    return
      Int64.toInt(Int64.ofInt(gid) & Int64.ofInt(~(Helper.GID_FLIPPED_HORIZONTALLY_FLAG | Helper.GID_FLIPPED_VERTICALLY_FLAG | Helper.GID_FLIPPED_DIAGONALLY_FLAG | Helper.GID_ROTATED_HEXAGONAL_120_FLAG)));
  }

  /**
   * Helper to check if gid is flipped horizontally
   * @param gid gid to check
   * @return True if flipped horizontally, else false
   */
  public static function isGidFlippedHorizontally(gid:Int):Bool {
    return Int64.ofInt(gid) & Int64.ofInt(Helper.GID_FLIPPED_HORIZONTALLY_FLAG) == Int64.ofInt(Helper.GID_FLIPPED_HORIZONTALLY_FLAG);
  }

  /**
   * Helper to check if gid is flipped vertically
   * @param gid gid to check
   * @return True if flipped vertically, else false
   */
  public static function isGidFlippedVertically(gid:Int):Bool {
    return Int64.ofInt(gid) & Int64.ofInt(Helper.GID_FLIPPED_VERTICALLY_FLAG) == Int64.ofInt(Helper.GID_FLIPPED_VERTICALLY_FLAG);
  }

  /**
   * Helper to check if gid is flipped diagonally
   * @param gid gid to check
   * @return True if flipped diagonally, else false
   */
  public static function isGidFlippedDiagonally(gid:Int):Bool {
    return Int64.ofInt(gid) & Int64.ofInt(Helper.GID_FLIPPED_DIAGONALLY_FLAG) == Int64.ofInt(Helper.GID_FLIPPED_DIAGONALLY_FLAG);
  }

  /**
   * Helper to check if gid is flipped hexagonal 120
   * @param gid gid to check
   * @return True if rotated hexagonal, else false
   */
  public static function isGidRotatedHexagonal120(gid:Int):Bool {
    return Int64.ofInt(gid) & Int64.ofInt(Helper.GID_ROTATED_HEXAGONAL_120_FLAG) == Int64.ofInt(Helper.GID_ROTATED_HEXAGONAL_120_FLAG);
  }

  /**
   * Helper to apply tile flipping
   * @param map map instance
   * @param t animated tile
   * @param flippable Flippable implementation
   * @param tileset tileset
   */
  public static function applyTileFlipping(map:tiledfl.Map, t:tiledfl.helper.AnimatedTile, flippable:tiledfl.helper.Flippable,
      tileset:tiledfl.Tileset):Void {
    var x:Float = t.x;
    var y:Float = t.y;
    // handle hexagonal stuff
    if (map.orientation == MapOrientationHexagonal) {
      // handle flipped diagonally
      if (flippable.isFlippedDiagonally()) {
        t.rotation += 60;
      }
      // handle rotated hexagonal
      if (flippable.isRotatedHexagonal120()) {
        t.rotation += 120;
      }
      // skip rest
      return;
    }
    // handle diagonal flipping
    if (flippable.isFlippedDiagonally()) {
      // handle combination of diagonally flipped and horizontal or vertical
      if (flippable.isFlippedHorizontally() || flippable.isFlippedVertically()) {
        t.width = -1 * tileset.tilewidth;
        t.x += tileset.tilewidth;
        // handle only diagonally flipped
      } else {
        t.height = -1 * tileset.tileheight;
      }
      // rotate clockwise by 90 degree
      t.rotation = 90;
    }
    // handle horizontally flipping
    if (flippable.isFlippedHorizontally()) {
      // handle not flipped diagonally
      if (!flippable.isFlippedDiagonally()) {
        t.width = -1 * tileset.tilewidth;
        t.x += tileset.tilewidth;
        // just flip horizontally
      } else {
        t.width = 1 * tileset.tilewidth;
      }
    }
    // handle vertical flipping
    if (flippable.isFlippedVertically()) {
      // handle diagonally not flipped
      if (!flippable.isFlippedDiagonally()) {
        t.height = -1 * tileset.tileheight;
        t.y += tileset.tileheight;
        // handle not flipped horizontally
      } else if (!flippable.isFlippedHorizontally()) {
        t.height = -1 * tileset.tileheight;
        t.x -= tileset.tilewidth;
        t.y += tileset.tileheight;
        // may be flipped diagonally and/or horizontally
      } else {
        t.width = -1 * tileset.tilewidth;
        t.y += tileset.tileheight;
      }
    }
    // set real x and y manually
    t.realX = x;
    t.realY = y;
  }
}
