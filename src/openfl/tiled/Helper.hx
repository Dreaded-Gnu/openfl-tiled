package openfl.tiled;

import haxe.io.Path;
import openfl.utils.ByteArray;

class Helper {
  // constants for flipped tiles
  public static inline var GID_FLIPPED_HORIZONTALLY_FLAG:UInt = 0x80000000;
  public static inline var GID_FLIPPED_VERTICALLY_FLAG:UInt = 0x40000000;
  public static inline var GID_FLIPPED_DIAGONALLY_FLAG:UInt = 0x20000000;
  public static inline var GID_ROTATED_HEXAGONAL_120_FLAG:UInt = 0x10000000;

  private static inline var BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

  /**
   * Helper to convert base64 to openfl byte array
   * @param data
   * @return ByteArray
   */
  public static function base64ToByteArray(data:String):ByteArray{
    var output:ByteArray = new ByteArray();
    //initialize lookup table
    var lookup:Array<Int> = new Array<Int>();
    for (c in 0...BASE64_CHARS.length){
      lookup[BASE64_CHARS.charCodeAt(c)] = c;
    }

    var i:Int = 0;
    var char:String = null;

    while (i < data.length - 3) {
      char = data.charAt(i);
      // Ignore whitespace
      if (char == " " || char == "\n" || char =='\r'){
        i++; continue;
      }

      //read 4 bytes and look them up in the table
      var a0:Int = lookup[data.charCodeAt(i)];
      var a1:Int = lookup[data.charCodeAt(i + 1)];
      var a2:Int = lookup[data.charCodeAt(i + 2)];
      var a3:Int = lookup[data.charCodeAt(i + 3)];

      // convert to and write 3 bytes
      if(a1 < 64) {
        output.writeByte((a0 << 2) + ((a1 & 0x30) >> 4));
      }
      if(a2 < 64) {
        output.writeByte(((a1 & 0x0f) << 4) + ((a2 & 0x3c) >> 2));
      }
      if(a3 < 64) {
        output.writeByte(((a2 & 0x03) << 6) + a3);
      }
      i += 4;
    }

    // Rewind & return decoded data
    output.position = 0;
    return output;
  }

  /**
   * Helper to convert csv data to array of integer
   * @param input
   * @return Array<Int>
   */
  public static function csvToArray(input:String):Array<Int> {
    var result:Array<Int> = new Array<Int>();
    // split rows by newline
    var rows:Array<String> = StringTools.trim(input).split("\n");
    // iterate through rows
    for(row in rows) {
      // skip empty rows
      if ("" == row) {
        continue;
      }
      // split row by comma to get entries
      var entries:Array<String> = row.split(",");
      // loop through entries
      for (entry in entries) {
        // skip empty strings
        if ("" == entry) {
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
   * @param path1
   * @param path2
   * @return String
   */
  public static function joinPath(path1:String, path2:String):String {
    if (path1 == null) {
      path1 = "";
    }
    if (path2 == null) {
      path2 = "";
    }
    return Path.normalize(path1 + path2);
  }
}
