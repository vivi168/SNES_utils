def to_little_endian(c)
  ('%04x' % c).scan(/.{2}/).reverse.join('')
end

def to5bits(c)
  c >> 3
end

def tobgr(r, g, b)
  r5 = to5bits(r)
  g5 = to5bits(g)
  b5 = to5bits(b)

  r5 | (g5 << 5) | (b5 << 10)
end

def hex2bgr(c)
  r = (c >> 16) & 0xff
  g = (c >> 8) & 0xff
  b = c & 0xff

  r5 = to5bits(r)
  g5 = to5bits(g)
  b5 = to5bits(b)

  r5 | (g5 << 5) | (b5 << 10)
end

def palette_to_hex_str(file)
  hex_str = ""
  palette = File.open(file)
  palette.each_line do |line|
    bgr = hex2bgr(line.to_i(16))
    hex_str += to_little_endian(bgr)
  end

  hex_str
end

def write_to_hex_file(str, file)
  File.open(file, 'w+b') do |file|
    p str
    file.write([str].pack('H*'))
  end
end

def extract_palette(file, out)
  s = palette_to_hex_str(file)
  p s
  write_to_hex_file(s, out)
end
