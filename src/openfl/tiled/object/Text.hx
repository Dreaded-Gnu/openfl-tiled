package openfl.tiled.object;

/**
 * Tiled text object
 */
class Text {
  /**
   * Font family to be used
   */
  public var fontfamily(default, null):String;

  /**
   * Pixel size
   */
  public var pixelsize(default, null):Int;

  /**
   * Wrap text
   */
  public var wrap(default, null):Int;

  /**
   * Text color
   */
  public var color(default, null):String;

  /**
   * Bold flag
   */
  public var bold(default, null):Int;

  /**
   * Italic flag
   */
  public var italic(default, null):Int;

  /**
   * Underline flag
   */
  public var underline(default, null):Int;

  /**
   * Strikeout flag
   */
  public var strikeout(default, null):Int;

  /**
   * Kerning
   */
  public var kerning(default, null):Int;

  /**
   * Horizontal align
   */
  public var halign(default, null):String;

  /**
   * Vertical align
   */
  public var valign(default, null):String;

  private var object:openfl.tiled.Object;

  /**
   * Constructor
   * @param node node data to parse
   * @param object object instance this object belongs to
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
