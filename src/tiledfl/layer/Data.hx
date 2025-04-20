package tiledfl.layer;

import openfl.errors.Error;
import openfl.utils.ByteArray;

/**
 * Layer data handling
 */
class Data {
  /**
   * Used encoding of data
   */
  public var encoding(default, null):String;

  /**
   * Used compression of data
   */
  public var compression(default, null):String;

  /**
   * Array of tiles represented in data
   */
  public var tile(default, null):Array<tiledfl.layer.Tile>;

  /**
   * Array of chunks represented in data
   */
  public var chunk(default, null):Array<tiledfl.layer.Chunk>;

  /**
   * Constructor
   * @param node xml representation of data
   */
  public function new(node:Xml) {
    this.encoding = node.get("encoding");
    this.compression = node.get("compression");

    this.tile = new Array<tiledfl.layer.Tile>();
    this.chunk = new Array<tiledfl.layer.Chunk>();

    for (child in node) {
      if (child.nodeType != Xml.Element) {
        continue;
      }
      switch (child.nodeName) {
        case "chunk":
          this.chunk.push(new tiledfl.layer.Chunk(child, this));
        case "tile":
          this.tile.push(new tiledfl.layer.Tile(Std.parseInt(child.get("gid"))));
      }
    }

    // handle no elements / parsed data
    if (0 >= this.tile.length && 0 >= this.chunk.length) {
      var chunk:String = node.firstChild().nodeValue;
      // handle encoding
      switch (this.encoding) {
        case "base64":
          // handle possible compression
          switch (this.compression) {
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
                this.tile.push(new tiledfl.layer.Tile(data.readInt()));
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
                this.tile.push(new tiledfl.layer.Tile(data.readInt()));
              }
          }
        case "csv":
          var tileIndexList:Array<Int> = Helper.csvToArray(chunk);
          for (tileId in tileIndexList) {
            this.tile.push(new tiledfl.layer.Tile(tileId));
          }
        default:
          throw new Error("no encoding not supported");
      }
    }
  }
}
