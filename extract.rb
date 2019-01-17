require 'chunky_png'
require 'matrix'
require './snes_utils'

def extract_pixels(file)
  image = ChunkyPNG::Image.from_file(file)

  px = image.pixels.map { |c| ChunkyPNG::Color.to_hex(c, false) }
  px = px.map { |c| c[1..-1].scan(/.{2}/).map { |b| b.to_i(16) } }

  pixels = []

  px.each do |rgb|
    bgr = tobgr(*rgb)
    pixels.push(to_little_endian(bgr))
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
    pixel_bitplanes.push(pixel_bitplane)
  end

  pixel_bitplanes.reverse
end

def bitplane_hex(pixel_idx_map, sprite_size)
  m = Matrix[*pixel_idx_map]
  # for now assume idx_map is 4x 8x8 sprites
  # quick and dirty, needed proof of work
  # TODO add loop/automate everything
  s1 = m.minor(0..7, 0..7).to_a
  s2 = m.minor(0..7, 8..15).to_a
  s3 = m.minor(8..15, 0..7).to_a
  s4 = m.minor(8..15, 8..15).to_a

  s1_bps = extract_bit_planes(s1, 4)
  s2_bps = extract_bit_planes(s2, 4)
  s3_bps = extract_bit_planes(s3, 4)
  s4_bps = extract_bit_planes(s4, 4)

  s1_out = bitplane_to_data(s1_bps)
  s2_out = bitplane_to_data(s2_bps)
  s3_out = bitplane_to_data(s3_bps)
  s4_out = bitplane_to_data(s4_bps)

  out = ""
  out = s1_out + s2_out + s3_out + s4_out

  p out.scan(/.{8}/)
  out.scan(/.{8}/).map { |b| "%02x" % b.to_i(2) }
end

def bitplane_to_data(bitplane)
  output = ""
  (0..7).each do |row|
    output += bitplane[0][row].join + bitplane[1][row].join
  end
  (0..7).each do |row|
    output += bitplane[2][row].join + bitplane[3][row].join
  end
  output
end

# TODO ask for file name
pixels = extract_pixels('link.png')
palette = extract_palette(pixels)
pixel_idx_map = extract_pixel_idx_map(pixels, palette)
# p pixel_idx_map
# bitplanes = extract_bit_planes(pixel_idx_map, 4)
bp = bitplane_hex(pixel_idx_map, 8)

p palette
p bp
write_to_hex_file(palette.join, 'SpriteColors.pal')
write_to_hex_file(bp.join, 'Sprites.vra')
