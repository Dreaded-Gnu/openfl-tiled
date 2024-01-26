package openfl.tiled;

class Group {
  public var id(default, null):Int;
  public var name(default, null):String;
  public var klass(default, null):String;
  public var offsetx(default, null):Int;
  public var offsety(default, null):Int;
  public var opacity(default, null):Float;
  public var visible(default, null):Int;
  public var tintcolor(default, null):String;
  public var properties(default, null):openfl.tiled.Properties;
  public var layer(default, null):Array<openfl.tiled.Layer>;
  public var objectgroup(default, null):Array<openfl.tiled.ObjectGroup>;
  public var imagelayer(default, null):Array<openfl.tiled.ImageLayer>;
  public var Group(default, null):Array<openfl.tiled.Group>;

  /**
   * Constructor
   */
  public function new() {}
}
