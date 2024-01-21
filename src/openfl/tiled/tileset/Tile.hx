package openfl.tiled.tileset;

class Tile {
  public var id(default, null):Int;
  public var type(default, null):String;
  public var terrain(default, null):String;
  public var probability(default, null):Int;
  public var x(default, null):Int;
  public var y(default, null):Int;
  public var width(default, null):Int;
  public var height(default, null):Int;
  public var properties(default, null):openfl.tiled.Properties;
  public var image(default, null):openfl.tiled.Image;
  public var objectgroup(default, null):openfl.tiled.ObjectGroup;
  public var animation(default, null):openfl.tiled.tileset.Animation;

  public function new() {
  }
}
