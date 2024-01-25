package openfl.tiled.tileset;

class Animation {
  public var frame(default, null):Array<openfl.tiled.tileset.Frame>;

  public function new(node:Xml) {
    this.frame = new Array<openfl.tiled.tileset.Frame>();
    for (child in node) {
      if (child.nodeType != Xml.Element) {
        continue;
      }
      switch (child.nodeName) {
        case "frame":
          this.frame.push(new openfl.tiled.tileset.Frame(child));
      }
    }
  }
}
