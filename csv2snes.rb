require 'csv'

class Csv2Snes
  def initialize(file_name, big_char:false, palette:0, v:false, h:false, p:false)
    @file_name = file_name
    @tilemap = []
    raise if palette < 0 || palette > 7
    @palette = palette
    @v_flip = v ? "1" : "0"
    @h_flip = h ? "1" : "0"
    @prio_bg3 = p ? "1" : "0"
    tnm = big_char ? 2 : 1
    row_offset = 16 * (tnm - 1)

    CSV.foreach(@file_name) do |row|
      raise if row.length != 32
      @tilemap += row.map { |r| (r.to_i - 1)*tnm + row_offset * ((r.to_i - 1)/8).to_i }
    end

    raise if @tilemap.length != 32*32
    dummy = 1023 # TODO: check max tile per tileset
    raise if @tilemap.map { |t| t < 0 || t > dummy }.include? true
  end

  def tile_to_data tile
    tile_name = "%010b" % tile
    palette_name = "%03b" % @palette

    tile_hl = @v_flip + @h_flip + @prio_bg3 + palette_name + tile_name
    tile_data = tile_hl.scan(/.{8}/)
    tile_data.reverse.map { |b| "%02x" % b.to_i(2) }

  end

  def tilemap_to_data
    bg_sc_data = []
    @tilemap.each do |tile|
      bg_sc_data.push(tile_to_data(tile))
    end
    bg_sc_data
  end

  def write
    File.open("#{@file_name}.map", 'w+b') do |file|
      file.write([tilemap_to_data.join].pack('H*'))
    end
  end
end

t = Csv2Snes.new 'assets/tilemap.csv', big_char: true

t.write
