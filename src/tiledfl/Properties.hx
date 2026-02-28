package tiledfl;

/**
 * Tiled properties representation
 */
@:allow(tiledfl.Layer)
class Properties extends tiledfl.RootObject
{
  /**
   * Array of properties
   */
  public var property(default, null):Array<tiledfl.Property>;

  /**
   * Constructor
   * @param node xml representation to be parsed
   */
  public function new(node:Xml)
  {
    super();
    this.property = new Array<tiledfl.Property>();
    for (child in node)
    {
      if (child.nodeType != Xml.Element)
      {
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
  private function propertyByName(name:String):Null<Property>
  {
    if (this.isDisposed())
    {
      return null;
    }
    for (property in this.property)
    {
      if (property.name == name)
      {
        return property;
      }
    }
    return null;
  }

  /**
   * Dispose method
   */
  override public function dispose():Void
  {
    super.dispose();
    this.property = cast this.destroyArray(this.property);
  }
}
