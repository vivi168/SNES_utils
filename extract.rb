require 'RMagick'
require './snes_utils'

include Magick

file = 'link.png'
image = ImageList.new(file)

pixels = []

image.each_pixel do |pixel, c, r|
  rgb = [pixel.red, pixel.green, pixel.blue].map { |c| c / 257 }
  bgr = tobgr(*rgb)
  pixels.append(to_little_endian(bgr))
end

uniq_colors = pixels.uniq
pp uniq_colors
p uniq_colors.count
p uniq_colors.index("7810")

p pixels.count
pixel_color_map = pixels.each_slice(16).to_a

pixel_idx_map = pixel_color_map.map { |a| a.map { |c| '%04b' % uniq_colors.index(c) } }

pixel_bitplanes = []
(0..3).each do |i|
  pixel_bitplane = pixel_idx_map.map { |a| a.map { |c| c[i] } }
  p pixel_bitplane
  pixel_bitplanes.append(pixel_bitplane)
end
