# ChangeLog

## 0.3.0 (YYYY-MM-DD)

* Fixed rendering of isometric maps (diamond and staggered)
* Reworked coordinate handling to float to prevent unnecessary int castings
* Changed `AnimatedTile` to set ENTER_FRAME handler when map is added to stage
* Extended `AnimatedTile` to remove ENTER_FRAME handler when map is removed from stage
* Adjusted nullable types to be typed with `Null<Type>`

## 0.2.0 (2025-04-26)

* Rearranged package from openfl.tiled to tiledfl
* Renamed TiledFL_use_asset to tiledfl_use_asset
* Renamed TiledFL_debug_render_object to tiledfl_debug_render_object

## 0.1.0 (2025-04-20)

* Initial release
