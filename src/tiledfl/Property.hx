package tiledfl;

/**
 * Tiled property
 */
class Property implements tiledfl.Disposable
{
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

  private var mDisposed:Bool;

  /**
   * Constructor
   * @param node xml representation to be parsed
   */
  public function new(node:Xml)
  {
    this.mDisposed = false;
    this.name = node.get("name");
    this.type = node.exists("type") ? node.get("type") : "string";
    this.propertytype = node.get("propertytype");
    this.value = node.get("value");
  }

  /**
   * Dispose method
   */
  public function dispose():Void
  {
    this.mDisposed = true;
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
