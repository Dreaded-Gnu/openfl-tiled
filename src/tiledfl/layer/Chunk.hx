package tiledfl.layer;

import openfl.errors.Error;
import openfl.utils.ByteArray;
import tiledfl.layer.Data;
import tiledfl.layer.Tile;

/**
 * Chunk layer implementation
 */
class Chunk extends RootObject
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
  public var tile(default, null):Array<Tile>;

  /**
   * Constructor
   * @param node chunk xml representation
   * @param data layer data handling
   */
  public function new(node:Xml, data:Data)
  {
    super();

    this.x = Std.parseInt(node.get("x"));
    this.y = Std.parseInt(node.get("y"));
    this.width = Std.parseInt(node.get("width"));
    this.height = Std.parseInt(node.get("height"));

    this.tile = new Array<Tile>();
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
              this.tile.push(new Tile(data.readInt()));
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
              this.tile.push(new Tile(data.readInt()));
            }
        }
      case "csv":
        var tileIndexList:Array<Int> = Helper.csvToArray(chunk);
        for (tileId in tileIndexList)
        {
          this.tile.push(new Tile(tileId));
        }
      default:
        throw new Error("no encoding not supported");
    }
  }

  /**
   * Dispose method
   */
  override public function dispose():Void
  {
    super.dispose();
    this.tile = cast this.destroyArray(this.tile);
  }
}
