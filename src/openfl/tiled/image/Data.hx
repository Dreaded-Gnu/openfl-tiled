package openfl.tiled.image;

import openfl.utils.ByteArray;
import openfl.errors.Error;

class Data {
  public var encoding(default, null):String;
  public var compression(default, null):String;
  public var data(default, null):ByteArray;

  /**
   * Constructor
   * @param node
   */
  public function new(node:Xml) {
    this.encoding = node.get("encoding");
    this.compression = node.get("compression");

    // handle no elements / parsed data
    var data:String = node.firstChild().nodeValue;
    // handle encoding
    switch (this.encoding) {
      case "base64":
        // handle possible compression
        switch (this.compression) {
          case "gzip":
            throw new Error("gzip compression not supported");
          case "zlib":
            // convert chunk to base 64 byte array
            this.data = Helper.base64ToByteArray(data);
            // decompress it
            this.data.uncompress();
            // set access mode
            this.data.endian = LITTLE_ENDIAN;
          case "zstd":
            throw new Error("zstd compression not supported");
          default:
            // convert chunk to base 64 byte array
            this.data = Helper.base64ToByteArray(data);
            // set access mode
            this.data.endian = LITTLE_ENDIAN;
        }
      default:
        throw new Error("no encoding not supported");
    }
  }
}
