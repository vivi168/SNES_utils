module SnesUtils
  class Tmx2Snes
    def initialize(file_path, big_char:false, palette:0, v:false, h:false, p:false)
      raise unless File.file? file_path
      @file_path = file_path
      @file_dir = File.dirname(@file_path)
      @file_name = File.basename(@file_path, File.extname(@file_path))
      @tilemap = []
      raise if palette < 0 || palette > 7
      @palette = palette
      @v_flip = v ? "1" : "0"
      @h_flip = h ? "1" : "0"
      @prio_bg3 = p ? "1" : "0"
      tnm = big_char ? 2 : 1 # big_char : 16x16 tiles. otherwise, 8x8 tiles
      row_offset = 16 * (tnm - 1) # Skip a row in case of 16x16 tiles ( tile #9 starts at index 32)

      doc = Nokogiri::XML(File.open(@file_path))
      csv_node = doc.xpath('//data').children.first.to_s

      csv = csv_node.split("\n").compact.reject { |e| e.empty? }.map { |row| row.split(',') }

      csv.each do |row|
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
      out = File.expand_path("#{@file_name}.map", @file_dir)
      File.open(out, 'w+b') do |file|
        file.write([tilemap_to_data.join].pack('H*'))
      end
    end
  end
end
