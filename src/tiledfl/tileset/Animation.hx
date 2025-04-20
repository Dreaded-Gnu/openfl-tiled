package tiledfl.tileset;

/**
 * Tileset animation class
 */
class Animation {
  /**
   * Array of frames of the animation
   */
  public var frame(default, null):Array<Frame>;

  /**
   * Constructor
   * @param node xml representation to parse
   */
  public function new(node:Xml) {
    this.frame = new Array<Frame>();
    for (child in node) {
      if (child.nodeType != Xml.Element) {
        continue;
      }
      switch (child.nodeName) {
        case "frame":
          this.frame.push(new Frame(child));
      }
    }
  }
}
