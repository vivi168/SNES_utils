module SnesUtils
  class Png2Snes
    CHAR_SIZE = 8

    def initialize(file_path, bpp:4, alpha:nil, mode7: false)
      @file_path = file_path
      @file_dir = File.dirname(@file_path)
      @file_name = File.basename(@file_path, File.extname(@file_path))
      @image = ChunkyPNG::Image.from_file(@file_path)

      @mode7 = mode7

      raise ArgumentError, 'Image width and height must be a multiple of sprite size' if (@image.width % CHAR_SIZE != 0) or (@image.height % CHAR_SIZE != 0)

      @pixels = pixels_to_bgr5
      @palette = @pixels.uniq


      if @mode7
        unshift_alpha(alpha) if alpha
        fill_palette
      else
        raise ArgumentError, 'BPP must be 2, 4, or 8' unless [2, 4, 8].include? bpp
        @bpp = bpp

        unshift_alpha(alpha) if alpha
        fill_palette
      end
    end

    def pixels_to_bgr5
      @image.pixels.map do |c|
        r = ((c >> 24) & 0xff) >> 3
        g = ((c >> 16) & 0xff) >> 3
        b = ((c >>  8) & 0xff) >> 3

        r | (g << 5) | (b << 10)
      end
    end

    def unshift_alpha(alpha)
      @palette.unshift(alpha)
    end

    def fill_palette
      target_size = @mode7 ? 128 : 2**@bpp
      missing_colors = target_size - @palette.count
      raise ArgumentError, "Palette size too large for target BPP (#{@palette.count})" if missing_colors < 0

      @palette += [0] * missing_colors
    end

    def write hex, file_path
      File.open(file_path, 'w+b') do |file|
        file.write([hex.join].pack('H*'))
      end
    end

    def write_palette
      palette_hex = @palette.map { |c| ('%04x' % c).scan(/.{2}/).reverse.join }
      write palette_hex, File.expand_path("#{@file_name}.pal", @file_dir)
    end

    def pixel_indices
      pix_idx = @pixels.map { |p| @palette.index(p) }
      pix_idx_bin = pix_idx.map { |i| "%0#{@bpp}b" % i }
      pix_idx_bin.map { |i| i.reverse }
    end

    def extract_sprites
      pixel_idx = pixel_indices

      sprite_per_row = @image.width / CHAR_SIZE
      sprite_per_col = @image.height / CHAR_SIZE
      sprite_per_sheet =  sprite_per_row * sprite_per_col

      sprites = []
      (0..sprite_per_sheet-1).each do |s|
        sprite = []
        (0..CHAR_SIZE-1).each do |r|
          offset = (s/sprite_per_row)*sprite_per_row * CHAR_SIZE**2 + s % sprite_per_row * CHAR_SIZE
          if @mode7
            sprite += @pixels[offset + r*sprite_per_row*CHAR_SIZE, CHAR_SIZE]
          else
            sprite += pixel_idx[offset + r*sprite_per_row*CHAR_SIZE, CHAR_SIZE]
          end
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
      @mode7 ? write_image_m7 : write_image_m06
    end

    def write_image_m06
      sprite_per_row = @image.width / CHAR_SIZE
      sprites = extract_sprites
      sprites_bitplanes = sprites.map { |s| extract_bitplanes s }

      image_bits = ""
      sprites_bitplanes.each do |sprite_bitplanes|
        sprite_bitplane_pairs = sprite_bitplanes.each_slice(2).to_a

        bitplane_bits = ""
        sprite_bitplane_pairs.each do |bitplane|
          (0..CHAR_SIZE-1).each do |r|
            offset = r*CHAR_SIZE
            bitplane_bits += bitplane[0][offset, CHAR_SIZE].join + bitplane[1][offset, CHAR_SIZE].join
          end
        end
        image_bits += bitplane_bits

      end

      image_hex = image_bits.scan(/.{8}/).map { |b| "%02x" % b.to_i(2) }
      write image_hex, File.expand_path("#{@file_name}.tiles", @file_dir)
    end

    def write_image_m7
      sprites = extract_sprites

      indices = sprites.flatten.map { |color| "%02x" % @palette.index(color) }

      write indices, File.expand_path("#{@file_name}.tiles", @file_dir)
    end
  end
end
