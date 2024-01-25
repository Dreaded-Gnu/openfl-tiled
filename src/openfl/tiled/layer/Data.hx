package openfl.tiled.layer;

import openfl.errors.Error;
import openfl.utils.ByteArray;
import haxe.io.BytesInput;
import haxe.zip.Reader;
import haxe.crypto.Base64;

class Data {
  public var encoding(default, null):String;
  public var compression(default, null):String;
  public var tile(default, null):Array<openfl.tiled.layer.Tile>;
  public var chunk(default, null):Array<openfl.tiled.layer.Chunk>;

  public function new(node:Xml) {
    this.encoding = node.get("encoding");
    this.compression = node.get("compression");

    this.tile = new Array<openfl.tiled.layer.Tile>();
    this.chunk = new Array<openfl.tiled.layer.Chunk>();

    for (child in node) {
      if (child.nodeType != Xml.Element) {
        continue;
      }
      switch (child.nodeName) {
        case "chunk":
          this.chunk.push(new openfl.tiled.layer.Chunk(child, this));
        case "tile":
          this.tile.push(new openfl.tiled.layer.Tile(Std.parseInt(child.get("gid"))));
      }
    }

    // handle no elements / parsed data
    if (0 >= this.tile.length && 0 >= this.chunk.length) {
      // get data
      var chunk:String = node.firstChild().nodeValue;
      // handle encoding
      switch (this.encoding)
      {
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
}