package tiledfl.tileset;

/**
 * Tileset animation class
 */
class Animation implements Disposable
{
  /**
   * Array of frames of the animation
   */
  public var frame(default, null):Array<Frame>;

  private var mDisposed:Bool;

  /**
   * Constructor
   * @param node xml representation to parse
   */
  public function new(node:Xml)
  {
    this.frame = new Array<Frame>();
    this.mDisposed = false;
    for (child in node)
    {
      if (child.nodeType != Xml.Element)
      {
        continue;
      }
      switch (child.nodeName)
      {
        case "frame":
          this.frame.push(new Frame(child));
      }
    }
  }

  /**
   * Dispose
   */
  public function dispose():Void
  {
    this.mDisposed = true;
    for (f in this.frame)
    {
      f.dispose();
    }
    this.frame = null;
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
