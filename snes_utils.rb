def hex2rgb(c)
  r = c[0,2].to_i(16)
  g = c[2,2].to_i(16)
  b = c[4,2].to_i(16)

  [r, g, b]
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


palette = File.open('palette.txt')
palette.each_line do |line|
  rgb = hex2rgb(line)
  bgr = tobgr(*rgb)
  p bgr.to_s(16)
end
