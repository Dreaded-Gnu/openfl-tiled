package tiledfl.layer;

import openfl.errors.Error;
import openfl.utils.ByteArray;

/**
 * Chunk layer implementation
 */
class Chunk implements Disposable
{
  /**
   * X coordinate the chunk starts
   */
  public var x(default, null):Float;

  /**
   * Y coordinate the chunk starts
   */
  public var y(default, null):Float;

  /**
   * Chunk width
   */
  public var width(default, null):Float;

  /**
   * Chunk height
   */
  public var height(default, null):Float;

  /**
   * Array of tiles in chunk
   */
  public var tile(default, null):Array<tiledfl.layer.Tile>;

  private var mDisposed:Bool;

  /**
   * Constructor
   * @param node chunk xml representation
   * @param data layer data handling
   */
  public function new(node:Xml, data:tiledfl.layer.Data)
  {
    this.mDisposed = false;

    this.x = Std.parseInt(node.get("x"));
    this.y = Std.parseInt(node.get("y"));
    this.width = Std.parseInt(node.get("width"));
    this.height = Std.parseInt(node.get("height"));

    this.tile = new Array<tiledfl.layer.Tile>();
    // get data
    var chunk:String = node.firstChild().nodeValue;
    // handle encoding
    switch (data.encoding)
    {
      case "base64":
        // handle possible compression
        switch (data.compression)
        {
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
            while (data.position < data.length)
            {
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
            while (data.position < data.length)
            {
              this.tile.push(new tiledfl.layer.Tile(data.readInt()));
            }
        }
      case "csv":
        var tileIndexList:Array<Int> = Helper.csvToArray(chunk);
        for (tileId in tileIndexList)
        {
          this.tile.push(new tiledfl.layer.Tile(tileId));
        }
      default:
        throw new Error("no encoding not supported");
    }
  }

  /**
   * Dispose method
   */
  public function dispose():Void
  {
    // set disposed flag
    this.mDisposed = true;
    // clear tiles
    for (t in this.tile)
    {
      t.dispose();
    }
    this.tile = null;
  }

  /**
   * Is disposed
   * @return true if disposed, else false
   */
  public function isDisposed():Bool
  {
    return this.mDisposed;
  }
}
