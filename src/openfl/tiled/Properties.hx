package openfl.tiled;

class Properties {
  public var property(default, null):Array<openfl.tiled.Property>;

  /**
   * Constructor
   * @param node
   */
  public function new(node:Xml) {
    // setup array
    this.property = new Array<openfl.tiled.Property>();
    for (child in node) {
      // skip non elements
      if (child.nodeType != Xml.Element) {
        continue;
      }
      // push property
      this.property.push(new openfl.tiled.Property(child));
    }
  }
}
