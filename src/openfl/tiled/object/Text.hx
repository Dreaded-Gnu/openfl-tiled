package openfl.tiled.object;

class Text {
  public var fontfamily(default, null):String;
  public var pixelsize(default, null):Int;
  public var wrap(default, null):Int;
  public var color(default, null):String;
  public var bold(default, null):Int;
  public var italic(default, null):Int;
  public var underline(default, null):Int;
  public var strikeout(default, null):Int;
  public var kerning(default, null):Int;
  public var halign(default, null):String;
  public var valign(default, null):String;

  private var object:openfl.tiled.Object;

  /**
   * Constructor
   * @param node
   * @param object
   */
  public function new(node:Xml, object:openfl.tiled.Object) {
    this.object = object;
    this.fontfamily = node.exists("fontfamily") ? node.get("fontfamily") : "sans-serif";
    this.pixelsize = node.exists("pixelsize") ? Std.parseInt(node.get("fontfamily")) : 16;
    this.wrap = node.exists("wrap") ? Std.parseInt(node.get("wrap")) : 0;
    this.color = node.get("color");
    this.bold = node.exists("bold") ? Std.parseInt(node.get("bold")) : 0;
    this.italic = node.exists("italic") ? Std.parseInt(node.get("italic")) : 0;
    this.underline = node.exists("underline") ? Std.parseInt(node.get("underline")) : 0;
    this.strikeout = node.exists("strikeout") ? Std.parseInt(node.get("strikeout")) : 0;
    this.kerning = node.exists("kerning") ? Std.parseInt(node.get("kerning")) : 1;
    this.halign = node.get("halign");
    this.valign = node.get("valign");
  }
}
