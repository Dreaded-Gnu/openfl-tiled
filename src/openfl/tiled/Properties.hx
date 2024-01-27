package openfl.tiled;

class Properties {
  public var property(default, null):Array<openfl.tiled.Property>;

  /**
   * Constructor
   * @param node
   */
  public function new(node:Xml) {
    this.property = new Array<openfl.tiled.Property>();
    for (child in node) {
      if (child.nodeType != Xml.Element) {
        // skip non elements
        continue;
      }
      // push property
      this.property.push(new openfl.tiled.Property(child));
    }
  }

  /**
   * Helper to get property by name
   * @param name
   * @return Property
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
