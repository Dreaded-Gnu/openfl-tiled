# openfl-tiled

Implementation of tiled map parsing for openfl and haxe

## working examples

| map                                                                         |  state    |
|-----------------------------------------------------------------------------|:---------:|
| sewers/sewers.tmx                                                           |  &check;  |
| desert/desert.tmx                                                           |  &check;  |
| desert_infinite/desert_infinite.tmx                                         |  &check;  |
| hexagonal-mini/hexagonal-mini.tmx                                           |  &check;  |
| isometric_grass_and_water/isometric_grass_and_water.tmx                     |  &check;  |
| isometric_staggered_grass_and_water/isometric_staggered_grass_and_water.tmx |  &check;  |
| island/island.tmx                                                           |  &cross;  |

## ToDo

- [x] Move map files into subfolder
- [x] Allow path to be passed into map parser to be able to load map assets from subfolder
- [x] Fix weird coordinate swapping
- [x] Add support for chunk handling in layer rendering
- [x] Finish isometric rendering
- [x] Finish staggered isometric rendering
- [ ] Add support for animations
- [ ] Implement image layers
- [ ] Implement object groups
