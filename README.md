# SNES Utils

Given an input image, extract color palette and sprite data, in a file format readable by the SNES.

As of now : we assume the palette is 4BPP, and a sprite is 8x8 pixels, the source image is composed of 4 sprites (16x16 pixels)

## Test

```
$ ruby extract.rb
$ ca65 --cpu 65816 -s -o SpriteDemo.o SpriteDemo.s
$ ld65 -C MemoryMap.cfg -o FirstSprite.smc SpriteDemo.o
```

Run with Snes9x or bsnes+.

You should see Link in the middle of the screen.

ASM files courtesy of [https://georgjz.github.io/snesaa04/](https://georgjz.github.io/snesaa04/)


## Goal :

* Detect number of colors in use (4, 16 or 256) and so the bit per pixel (2BPP, 4BPP or 8BPP)
* Determine the color palette accordingly, save it to binary file
* Given sprite size, extract the sprites and save it to binary file

# Tools

```
gem install chunky_png
```
