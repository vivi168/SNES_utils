# SNES Utils

* Given an input image, extract color palette and character data, in a file format readable by the SNES. (Read: that you can load into VRAM/CGRAM as is).
* Given a CSV file (generated with Tiled), generate a tilemap loadable in the SNES vram.

Warning: Tileset should be 128 pixel wide for best usability.

## How to use

```
$ ruby png2snes.rb -f assets/mario.png
$ ruby png2snes.rb -f assets/background.png
$ ruby csv2snes.rb
$ sh make.sh
```

Run with Snes9x or bsnes+.

You should see Mario in the middle of the screen.

At first, I used the source from [https://georgjz.github.io/snesaa04/](https://georgjz.github.io/snesaa04/)

As of now, I've rewritten everything to use DMA. I will use this base to make a small SNES game.

# TODO

* I should make a Gem, combining Png2Snes and Csv2Snes
* Convert Tiled .tmx files into usable SNES tilemap files directly (instead of manually extracting the csv from the TMX)
* Support tilemap larger than 32x32 tiles
