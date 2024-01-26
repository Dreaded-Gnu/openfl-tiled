package openfl.tiled.layer;

import openfl.errors.Error;
import openfl.utils.ByteArray;

class Chunk {
  public var x(default, null):Int;
  public var y(default, null):Int;
  public var width(default, null):Int;
  public var height(default, null):Int;
  public var tile(default, null):Array<openfl.tiled.layer.Tile>;

  /**
   * Constructor
   * @param node
   * @param data
   */
  public function new(node:Xml, data:openfl.tiled.layer.Data) {
    this.x = Std.parseInt(node.get("x"));
    this.y = Std.parseInt(node.get("y"));
    this.width = Std.parseInt(node.get("width"));
    this.height = Std.parseInt(node.get("height"));

    this.tile = new Array<openfl.tiled.layer.Tile>();
    // get data
    var chunk:String = node.firstChild().nodeValue;
    // handle encoding
    switch (data.encoding) {
      case "base64":
        // handle possible compression
        switch (data.compression) {
          case "gzip":
            throw new Error("gzip compression not supported");
          case "zlib":
            // convert chunk to base 64 byte array
            var data:ByteArray = Helper.base64ToByteArray(chunk);
            // decompress it
            data.uncompress();
            // set access mode
            data.endian = LITTLE_ENDIAN;
            // read tiles and push them
            while (data.position < data.length) {
              this.tile.push(new openfl.tiled.layer.Tile(data.readInt()));
            }
          case "zstd":
            throw new Error("zstd compression not supported");
          default:
            // convert chunk to base 64 byte array
            var data:ByteArray = Helper.base64ToByteArray(chunk);
            // set access mode
            data.endian = LITTLE_ENDIAN;
            // read tiles and push them
            while (data.position < data.length) {
              this.tile.push(new openfl.tiled.layer.Tile(data.readInt()));
            }
        }
      case "csv":
        var tileIndexList:Array<Int> = Helper.csvToArray(chunk);
        for (tileId in tileIndexList) {
          this.tile.push(new openfl.tiled.layer.Tile(tileId));
        }
      default:
        throw new Error("no encoding not supported");
    }
  }
}
