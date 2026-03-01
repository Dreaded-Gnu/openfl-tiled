# TiledFL

Implementation of tiled map parsing for openfl and haxe.

## Usage example

```haxe
// initialize map
var map:tiledfl.TMap = new tiledfl.TMap(
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

#### tiledfl.TMap::load

```haxe
public function load():Void;
```

Function starts loading of the map and accepts no parameter. Once completed `Event.COMPLETE` is fired.

#### tiledfl.TMap::resize

```haxe
public function resize(width:Float, height:Float):Void;
```

Function to resize the map. Method accepts width and height as parameter, recreates the scroll rect and rerenders the whole map.

#### tiledfl.TMap::render

```haxe
public function render(offsetX:Float = 0, offsetY:Float = 0):Void;
```

Calling renders the map. The function accepts two optional parameters to render with offset x and/or y. In case it was already rendered and offsets don't differ nothing will be done.

#### tiledfl.TMap::collides

```haxe
public function collides(x:Float, y:Float, width:Float, height:Float):Bool;
```

Check whether a rectangle starting at x/y width specific width and height collides with a collidable object. Collidable objects are tiles that have a property `collides` set to `"true"`, objects that have `collision` set as name or objects that have type set to `collision`

#### tiledfl.TMap::dispose

```haxe
public function dispose():Void;
```

Dispose whole map and all related instances.

#### tiledfl.TMap::objectgroupByName

```haxe
public function objectgroupByName(name:String):Null<tiledfl.ObjectGroup>
```

Helper method to get object group by set name if existing

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
