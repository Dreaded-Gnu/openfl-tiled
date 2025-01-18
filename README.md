# openfl-tiled

Implementation of tiled map parsing for openfl and haxe.

## Usage example

```haxe
// load map
var map:openfl.tiled.Map = new openfl.tiled.Map(
  "/tiled/rpg/",
  "/tiled/rpg/island.tmx",
  stage.stageWidth,
  stage.stageHeight
);
map.addEventListener(Event.COMPLETE, onMapLoadComplete);

...

function onMapLoadComplete(event:Event):Void {
  map.removeEventListener(Event.COMPLETE, onMapLoadComplete);
  // add child to stage (necessary for animations)
  stage.addChild(tilemap);
  // render map
  map.render();
}
```

## Installation

openfl-tiled2 is currently not published to haxelib, so to install you've to use git install.

```bash
haxelib git openfl-tiled2 https://github.com/Dreaded-Gnu/openfl-tiled
```
