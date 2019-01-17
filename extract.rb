require 'RMagick'
require './snes_utils'

include Magick

def extract_pixels(file)
  image = ImageList.new(file)

  pixels = []

  image.each_pixel do |pixel, c, r|
    rgb = [pixel.red, pixel.green, pixel.blue].map { |c| c / 257 }
    bgr = tobgr(*rgb)
    pixels.append(to_little_endian(bgr))
  end

  pixels
end

# for now we assume we work with 4bpp, 16 colors
def extract_palette(pixels)
  palette = pixels.uniq
  # fill palette with black if not 16 colors
  if palette.count < 16
    palette += ["0000"] * (16 - palette.count)
  end

  palette
end

def extract_pixel_idx_map(pixels, palette)
  pixel_color_map = pixels.each_slice(16).to_a

  pixel_idx_map = pixel_color_map.map { |a| a.map { |c| '%04b' % palette.index(c) } }
end

def extract_bit_planes(idx_map, bpp)
  pixel_bitplanes = []
  (0..bpp-1).each do |i|
    pixel_bitplane = idx_map.map { |a| a.map { |c| c[i] } }
    pixel_bitplanes.append(pixel_bitplane)
  end

  pixel_bitplanes
end

pixels = extract_pixels('link.png')
palette = extract_palette(pixels)
pixel_idx_map = extract_pixel_idx_map(pixels, palette)
bitplanes = extract_bit_planes(pixel_idx_map, 4)

p bitplanes
