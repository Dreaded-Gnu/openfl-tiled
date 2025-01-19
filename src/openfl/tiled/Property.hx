package openfl.tiled;

/**
 * Tiled property
 */
class Property {
  /**
   * Name
   */
  public var name(default, null):String;

  /**
   * Type
   */
  public var type(default, null):String;

  /**
   * Property type
   */
  public var propertytype(default, null):String;

  /**
   * Property value
   */
  public var value(default, null):String;

  /**
   * Constructor
   * @param node xml representation to be parsed
   */
  public function new(node:Xml) {
    this.name = node.get("name");
    this.type = node.exists("type") ? node.get("type") : "string";
    this.propertytype = node.get("propertytype");
    this.value = node.get("value");
  }
}
