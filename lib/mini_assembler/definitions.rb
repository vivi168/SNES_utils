# frozen_string_literal: true

module SnesUtils
  class Definitions
    HEX_DIGIT = '[0-9a-f]'

    BYTE_LOC_REGEX = /^#{HEX_DIGIT}{1,4}$/i.freeze
    BYTE_RANGE_REGEX = /^(#{HEX_DIGIT}{1,4})\.+(#{HEX_DIGIT}{1,4})$/i.freeze
    BYTE_SEQUENCE_REGEX = /^(#{HEX_DIGIT}{1,4}):\s*([0-9a-f ]+)$/i.freeze
    READ_BYTE_SEQUENCE_REGEX = /^(.*):\s*\.db\s+([0-9a-f ]+)$/i.freeze
    DISASSEMBLE_REGEX = /^(#{HEX_DIGIT}{,4})l/i.freeze
    SWITCH_BANK_REGEX = %r{^(#{HEX_DIGIT}{1,2})/$}i.freeze
    FLIP_MX_REG_REGEX = /^([01])=([xm])$/i.freeze
    WRITE_REGEX = /^\.write\s*(.*)$/i.freeze
    INCBIN_REGEX = /^(#{HEX_DIGIT}{1,4}):\s*\.incbin\s+(.*)$/i.freeze
    READ_INCBIN_REGEX = /^(.*):\s*\.incbin\s+(.*)$/i.freeze
    READ_INCSRC_REGEX = /^\s*\.incsrc\s+(.*)$/i.freeze
    READ_REGEX = /^((#{HEX_DIGIT}{1,4}):\s*)*\.read\s+(.*)$/i.freeze
    READ_BANK_SWITCH = /^\.bank\s+(#{HEX_DIGIT}{1,2})$/i.freeze
    READ_ADDR_SWITCH = /^\.addr\s+(#{HEX_DIGIT}{1,4})$/i.freeze
  end
end
