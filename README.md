# openfl-tiled

Implementation of tiled map parsing for openfl and haxe

## working examples

| map                                     |  state    |
|-----------------------------------------|:---------:|
| sewers.tmx                              |  &check;  |
| desert.tmx                              |  &check;  |
| hexagonal-mini.tmx                      |  &check;  |
| isometric_grass_and_water.tmx           |  &cross;  |
| isometric_staggered_grass_and_water.tmx |  &cross;  |
| island.tmx                              |  &cross;  |

## ToDo

- [ ] Move map files into subfolder
- [ ] Allow path to be passed into map parser to be able to load map assets from subfolder
- [x] Fix weird coordinate swapping
- [x] Add support for chunk handling in layer rendering
- [x] Finish isometric rendering
- [x] Finish staggered isometric rendering
- [ ] Add support for animations
- [ ] Implement image layers
- [ ] Implement object groups
