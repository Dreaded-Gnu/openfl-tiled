package tiledfl;

/**
 * Tiled properties representation
 */
class Properties implements Disposable
{
  /**
   * Array of properties
   */
  public var property(default, null):Array<tiledfl.Property>;

  private var mDisposed:Bool;

  /**
   * Constructor
   * @param node xml representation to be parsed
   */
  public function new(node:Xml)
  {
    this.mDisposed = false;
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
  public function propertyByName(name:String):Null<Property>
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
  public function dispose():Void
  {
    this.mDisposed = true;
    for (p in this.property)
    {
      p.dispose();
    }
    this.property = null;
  }

  /**
   * Is disposed
   * @return true if disposed, else false
   */
  public function isDisposed():Bool
  {
    return this.mDisposed;
  }
}
