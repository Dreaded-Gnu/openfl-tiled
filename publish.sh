#!/bin/sh
rm -f TiledFL.zip
zip -r TiledFL.zip src README.md CHANGELOG.md LICENSE.md haxelib.json -x src/Main.hx
haxelib submit TiledFL.zip DreadedGnu
