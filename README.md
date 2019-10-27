# SNES Utils

* `png2snes`: Given an input image, extract color palette and character data, in a file format readable by the SNES. (Read: that you can load into VRAM/CGRAM as is).
* `tmx2snes`: Given a TMX file (generated with Tiled), generate a tilemap loadable in the SNES vram.
* `mini_assembler`: System monitor/Mini Assembler clone. With it you can examine (hexdump) any area of a ROM, disassemble any range, inject data anywhere (either raw binary/hex or assemble 65816 instructions directly). You can even program a full game with it!

Warning: Tileset should be 128 pixel wide for best usability.

## How to use

```
$ png2snes -f file.png
$ tmx2snes -f file.tmx [-s tile_size]
$ mini_assembler [-f rom.smc]
```

## Demo

For now, you need ca65 to build the demo. run `make`, it should produce `demo.smc`.

# TODO

* I should make a Gem, combining Png2Snes and Tmx2Snes
* Chose output directory
* Support 32x64, 64x32 and 64x64 tilemaps
* Add a way to set the flip bits per tile (an additional CSV file?)
