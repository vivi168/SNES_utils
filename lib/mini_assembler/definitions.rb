module SnesUtils
  class Definitions
    HEX_DIGIT = '[0-9a-f]'

    BYTE_LOC_REGEX = /^#{HEX_DIGIT}{1,4}$/i
    BYTE_RANGE_REGEX = /^(#{HEX_DIGIT}{1,4})\.+(#{HEX_DIGIT}{1,4})$/i
    BYTE_SEQUENCE_REGEX = /^(#{HEX_DIGIT}{1,4}):\s*([0-9a-f ]+)$/i
    DISASSEMBLE_REGEX = /^(#{HEX_DIGIT}{,4})l/i
    SWITCH_BANK_REGEX = /^(#{HEX_DIGIT}{1,2})\/$/i
    FLIP_MX_REG_REGEX = /^([01])=([xm])$/i
    WRITE_REGEX = /^\.write\s*(.*)$/i
    INCBIN_REGEX = /^(#{HEX_DIGIT}{1,4}):\s*\.incbin\s+(.*)$/i
    READ_REGEX = /^((#{HEX_DIGIT}{1,4}):\s*)*\.read\s+(.*)$/i
  end
end
