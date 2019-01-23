require 'chunky_png'
require 'matrix'
require 'optparse'

class Png2Snes
  def initialize(file_name, sprite_size:8, bpp:4, alpha:nil)
    @file_name = file_name
    @image = ChunkyPNG::Image.from_file(@file_name)
    @pixels = pixels_to_bgr5

    @palette = @pixels.uniq

    raise ArgumentError, 'Sprite must be 8, 16, 32 or 64 pixels' unless [8, 16, 32, 64].include? sprite_size
    @sprite_size = sprite_size

    raise ArgumentError, 'BPP must be 2, 4, or 8' unless [2, 4, 8].include? bpp
    @bpp = bpp

    raise ArgumentError, 'Image width and height must be a multiple of sprite size' if (@image.width % sprite_size != 0) or (@image.height % sprite_size != 0)

    alpha_first if alpha
    fill_palette
  end

  def pixels_to_bgr5
    @image.pixels.map do |c|
      r = ((c >> 24) & 0xff) >> 3
      g = ((c >> 16) & 0xff) >> 3
      b = ((c >>  8) & 0xff) >> 3

      r | (g << 5) | (b << 10)
    end
  end

  def alpha_first
  end

  def fill_palette
    target_size = 2**@bpp
    missing_colors = target_size - @palette.count
    raise ArgumentError, 'Palette size to large for target BPP' if missing_colors < 0

    @palette += [0] * missing_colors
  end

  def write hex, file_name
    File.open(file_name, 'w+b') do |file|
      file.write([hex.join].pack('H*'))
    end
  end

  def write_palette
    palette_hex = @palette.map { |c| ('%04x' % c).scan(/.{2}/).reverse.join }
    write palette_hex, "#{@file_name}.pal"
  end

  def pixel_indices
    pix_idx = @pixels.map { |p| @palette.index(p) }
    pix_idx_bin = pix_idx.map { |i| "%0#{@bpp}b" % i }
    pix_idx_bin.map { |i| i.reverse }
  end

  def extract_sprites
    pixel_idx = pixel_indices

    sprite_per_row = @image.width / @sprite_size
    sprite_per_col = @image.height / @sprite_size
    sprite_per_sheet =  sprite_per_row * sprite_per_col

    sprites = []
    (0..sprite_per_sheet-1).each do |s|
      sprite = []
      (0..@sprite_size-1).each do |r|
        offset = (s/sprite_per_row)*sprite_per_row * @sprite_size**2 + s % sprite_per_row * @sprite_size
        sprite += pixel_idx[offset + r*sprite_per_row*@sprite_size, @sprite_size]
      end
      sprites.push(sprite)
    end

    sprites
  end

  def extract_bitplanes sprite
    bitplanes = []
    (0..@bpp-1).each do |plane|
      bitplanes.push sprite.map { |p| p[plane] }
    end

    bitplanes
  end

  def write_image
    sprite_per_row = @image.width / @sprite_size
    sprites = extract_sprites
    sprites_bitplanes = sprites.map { |s| extract_bitplanes s }

    image_bits = ""
    sprites_bitplanes.each do |sprite_bitplanes|
      sprite_bitplane_pairs = sprite_bitplanes.each_slice(2).to_a

      bitplane_bits = ""
      sprite_bitplane_pairs.each do |bitplane|
        (0..@sprite_size-1).each do |r|
          offset = r*@sprite_size
          bitplane_bits += bitplane[0][offset, @sprite_size].join + bitplane[1][offset, @sprite_size].join
        end
      end
      image_bits += bitplane_bits

    end

    image_hex = image_bits.scan(/.{8}/).map { |b| "%02x" % b.to_i(2) }
    write image_hex, "#{@file_name}.vra"
  end

end

options = {}
OptionParser.new do |opts|
  opts.on('-f', '--file FILENAME', 'PNG source file') { |o| options[:filename] = o }
end.parse!

raise OptionParser::MissingArgument, 'Must specify PNG source file' if options[:filename].nil?

c = Png2Snes.new options[:filename]
c.write_palette
c.write_image