# TiledFL

Implementation of tiled map parsing for openfl and haxe.

## Usage example

```haxe
// initialize map
var map:openfl.tiled.Map = new openfl.tiled.Map(
  "/tiled/rpg/",
  "/tiled/rpg/island.tmx",
  stage.stageWidth,
  stage.stageHeight
);
// set load complete handler
map.addEventListener(Event.COMPLETE, onMapLoadComplete);
// start loading the map
map.load();

...

function onMapLoadComplete(event:Event):Void {
  // remove event listener again
  map.removeEventListener(Event.COMPLETE, onMapLoadComplete);
  // add child to stage (necessary for animations)
  stage.addChild(map.tilemap);
}
```

## Installation

TiledFL is currently not published to haxelib, so to install you've to use git install.

```bash
haxelib git TiledFL https://github.com/Dreaded-Gnu/openfl-tiled
```

## Configuration options

Following configuration options are possible via defines.

### TiledFL_use_asset

When defined via `project.xml` implementation uses openfl `Assets` class to fetch all the necessary data.

### TiledFL_debug_render_object

When defined tiled mapeditor objects are rendered by default with red color. This color can be changed by manipulating property `debugRenderObjectColor` of map instance.
