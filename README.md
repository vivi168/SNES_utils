# SNES Utils

Given an input image, extract color palette and sprite data, in a file format readable by the SNES.

As of now : we assume the palette is 4BPP, and a sprite is 8x8 pixels, the source image is composed of 4 sprites (16x16 pixels)

Goal :

* Detect number of colors in use (4, 16 or 256) and so the bit per pixel (2BPP, 4BPP or 8BPP)
* Determine the color palette accordingly, save it to binary file
* Given sprite size, extract the sprites and save it to binary file

# Tools

on macOS :

```
brew install imagemagick@6
export PATH="/usr/local/opt/imagemagick@6/bin:$PATH"
brew link --force imagemagick@6
gem install rmagick
```
