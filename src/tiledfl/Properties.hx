package tiledfl;

/**
 * Tiled properties
 */
class Properties {
  /**
   * Array of properties
   */
  public var property(default, null):Array<tiledfl.Property>;

  /**
   * Constructor
   * @param node xml representation to be parsed
   */
  public function new(node:Xml) {
    this.property = new Array<tiledfl.Property>();
    for (child in node) {
      if (child.nodeType != Xml.Element) {
        // skip non elements
        continue;
      }
      // push property
      this.property.push(new tiledfl.Property(child));
    }
  }

  /**
   * Helper to get property by name
   * @param name Name to get property
   * @return Found property or null
   */
  public function propertyByName(name:String):Property {
    for (property in this.property) {
      if (property.name == name) {
        return property;
      }
    }
    return null;
  }
}
