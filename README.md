# openfl-tiled

Implementation of tiled map parsing for openfl and haxe.

## Usage example

```haxe
// create new tilemap
var tilemap:openfl.display.Tilemap = new openfl.display.Tilemap(
  stage.stageWidth,
  stage.stageHeight
);
// add child to stage (necessary for animations)
stage.addChild(tilemap);
// load map
var map:openfl.tiled.Map = new openfl.tiled.Map(
  "/tiled/rpg/",
  "/tiled/rpg/island.tmx",
  tilemap
);
map.addEventListener(Event.COMPLETE, onMapLoadComplete);

...

function onMapLoadComplete(event:Event):Void {
  map.removeEventListener(Event.COMPLETE, onMapLoadComplete);
  // render map
  map.render();
}
```

## Installation

openfl-tiled2 is currently not published to haxelib, so to install you've to use git install.

```bash
haxelib git openfl-tiled2 https://github.com/Dreaded-Gnu/openfl-tiled
```
