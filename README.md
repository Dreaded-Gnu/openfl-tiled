# TiledFL

Implementation of tiled map parsing for openfl and haxe.

## Usage example

```haxe
// initialize map
var map:tiledfl.Map = new tiledfl.Map(
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
  // initially render the map
  map.render();
}
```

### Functions

Below is a list of usual functions.

#### tiledfl.Map::load

```haxe
public function load():Void;
```

Function starts loading of the map and accepts no parameter. Once completed `Event.COMPLETE` is fired.

#### tiledfl.Map::resize

```haxe
public function resize(width:Int, height:Int):Void;
```

Function to resize the map. Method accepts width and height as parameter, recreates the scroll rect and rerenders the whole map.

#### tiledfl.Map::render

```haxe
public function render(offsetX:Int = 0, offsetY:Int = 0):Void;
```

Calling renders the map. The function accepts two optional parameters to render with offset x and/or y. In case it was already rendered and offsets don't differ nothing will be done.

#### tiledfl.Map::collides

```haxe
public function collides(x:Int, y:Int, width:Int, height:Int):Bool;
```

Check whether a rectangle starting at x/y width specific width and height collides with a collidable object. Collidable objects are tiles that have a property `collides` set to `"true"`, objects that have `collision` set as name or objects that have type set to `collision`

## Installation

Using TiledFL source install.

```bash
haxelib git TiledFL https://github.com/Dreaded-Gnu/openfl-tiled
```

Using TiledFL normal install

```bash
haxelib install TiledFL
```

## Configuration options

Following configuration options are possible via defines.

### tiledfl_use_asset

When defined via `project.xml` implementation uses openfl `Assets` class to fetch all the necessary data.

### tiledfl_debug_render_object

When defined tiled mapeditor objects are rendered by default with red color. This color can be changed by manipulating property `debugRenderObjectColor` of map instance.
