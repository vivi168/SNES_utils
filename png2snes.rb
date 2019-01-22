require 'chunky_png'
require 'matrix'
require 'optparse'

class Png2Snes
  attr_accessor :pixels, :palette

  def initialize(file_name, sprite_size:8, bpp:4, alpha:nil)
    @file_name = file_name
    image = ChunkyPNG::Image.from_file(@file_name)
    @pixels = image.pixels.map do |c|
      r = ((c >> 24) & 0xff) >> 3
      g = ((c >> 16) & 0xff) >> 3
      b = ((c >>  8) & 0xff) >> 3

      r | (g << 5) | (b << 10)
    end

    @palette = @pixels.uniq

    raise ArgumentError, 'Sprite must be 8, 16, 32 or 64 pixels' unless [8, 16, 32, 64].include? sprite_size
    @sprite_size = sprite_size

    raise ArgumentError, 'BPP must be 2, 4, or 8' unless [2, 4, 8].include? bpp
    @bpp = bpp

    raise ArgumentError, 'Image width and height must be a multiple of sprite size' if (image.width % sprite_size != 0) or (image.height % sprite_size != 0)

    alpha_first if alpha
    fill_palette
  end

  def alpha_first
  end

  def fill_palette
    target_size = 2**@bpp
    missing_colors = target_size - palette.count
    raise ArgumentError, 'Palette size to large for target BPP' if missing_colors < 0

    @palette += [0] * missing_colors
  end

  def write_palette
    palette_hex = @palette.map { |c| ('%04x' % c).scan(/.{2}/).reverse.join }

    File.open("#{@file_name}.pal", 'w+b') do |file|
      file.write([palette_hex.join].pack('H*'))
    end
  end

  def pixel_indices
    pix_idx = @pixels.map { |p| @palette.index(p) }
    pix_idx_bin = pix_idx.map { |i| "%0#{@bpp}b" % i }
    pix_idx_bin_lsb = pix_idx_bin.map { |i| i.reverse }
  end

  def extract_bitplanes
    pixel_idx = pixel_indices
    bitplanes = []
    (0..@bpp-1).each do |plane|
      bitplanes.push pixel_idx.map { |p| p[plane] }
    end

    bitplanes
  end

  def write_image
    pixel_idx = pixel_indices
    bitplanes = extract_bitplanes
    p bitplanes
  end

end

c = Png2Snes.new 'link.png'
c.write_palette
c.write_image
