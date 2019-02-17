# SNES Utils

* Given an input image, extract color palette and character data, in a file format readable by the SNES. (Read: that you can load into VRAM/CGRAM as is).
* Given a TMX file (generated with Tiled), generate a tilemap loadable in the SNES vram.

Warning: Tileset should be 128 pixel wide for best usability.

## How to use

```
$ ruby png2snes.rb -f file.png
$ ruby tmx2snes.rb -f file.tmx [-s tile_size]
```

## Demo

You need ca65 to build the demo. run `make`, it should produce `demo.smc`

# TODO

* I should make a Gem, combining Png2Snes and Tmx2Snes
* Chose output directory
* Support 32x64, 64x32 and 64x64 tilemaps
* Add a way to set the flip bits per tile (an additional CSV file?)
