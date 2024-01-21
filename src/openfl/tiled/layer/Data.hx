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
      /// FIXME: HANDLE POSSIBLE ELEMENTS LIKE CHUNKS
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
              var data:ByteArray = base64ToByteArray(chunk);
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
              var data:ByteArray = base64ToByteArray(chunk);
              // set access mode
              data.endian = LITTLE_ENDIAN;
              // read tiles and push them
              while (data.position < data.length) {
                this.tile.push(new openfl.tiled.layer.Tile(data.readInt()));
              }
          }
        case "csv":
          // split rows by newline
          var rows:Array<String> = StringTools.trim(chunk).split("\n");
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
              this.tile.push(new openfl.tiled.layer.Tile(Std.parseInt(entry)));
            }
          }
        default:
          throw new Error("no encoding not supported");
      }
    }
  }

  private static inline var BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
  private static function base64ToByteArray(data:String):ByteArray{
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
}