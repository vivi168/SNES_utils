module Regexes
  HEX8  = '\$?([0-9a-f]{1,2})'
  HEX16 = '\$?([0-9a-f]{3,4})'
  HEX24 = '\$?([0-9a-f]{5,6})'

  IMM8  = "\##{HEX8}"
  IMM16 = "\##{HEX16}"
end
