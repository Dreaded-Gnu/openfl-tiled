package openfl.tiled;

class Property {
  public var name(default, null):String;
  public var type(default, null):String;
  public var propertytype(default, null):String;
  public var value(default, null):String;

  /**
   * Constructor
   * @param node
   */
  public function new(node:Xml) {
    this.name = node.get("name");
    this.type = node.exists("type") ? node.get("type") : "string";
    this.propertytype = node.get("propertytype");
    this.value = node.get("value");
  }
}
