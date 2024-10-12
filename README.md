# openfl-tiled

Implementation of tiled map parsing for openfl and haxe

## working examples

| map                                                                               |  state    |
|-----------------------------------------------------------------------------------|:---------:|
| tiled/sewers/sewers.tmx                                                           |  &check;  |
| tiled/desert/desert.tmx                                                           |  &check;  |
| tiled/desert_infinite/desert_infinite.tmx                                         |  &check;  |
| tiled/hexagonal-mini/hexagonal-mini.tmx                                           |  &check;  |
| tiled/isometric_grass_and_water/isometric_grass_and_water.tmx                     |  &check;  |
| tiled/isometric_staggered_grass_and_water/isometric_staggered_grass_and_water.tmx |  &check;  |
| tiled/rpg/island.tmx                                                              |  &check;  |
| tiled/forest/forest.tmx                                                           |  &check;  |
| tiled/perspective_walls/perspective_walls.tmx                                     |  &check;  |

## Known issues

- [x] tiled/sewers/sewers.tmx second layer looses transparency when "scrolling"

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
