# SNES Utils

## Tools

* `mini_assembler`: System monitor/Mini Assembler clone. With it you can examine (hexdump) any area of a ROM, disassemble any range, inject data anywhere (either raw binary/hex or assemble 65816 instructions directly). You can even program a full game with it (if you're brave enough)!
* `png2snes`: Given an input image, extract color palette and character data, in a file format readable by the SNES. (Read: that you can load into VRAM/CGRAM as is).
* `tmx2snes`: Given a TMX file (generated with Tiled), generate a tilemap loadable in the SNES vram.
* `vas`: 65816, spc700 and superfx macro assembler

Warning: Tileset should be 128 pixel wide for best usability.

## How to use

see snake/build for each tool usage example.

## Demo

Snake : This is a clone of the well known snake game. It was build solely with the tools found in this repo.
