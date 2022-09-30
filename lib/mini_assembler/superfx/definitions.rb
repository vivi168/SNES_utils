# frozen_string_literal: true

module SnesUtils
  module Superfx
    class Definitions
      HEX_DIGIT = '[0-9a-f]'
      REG   = "[rR](\\d{1,2})"
      LNK   = "([1-4])"
      HEX   = "\\$?(#{HEX_DIGIT})"
      HEX8  = "\\$?(#{HEX_DIGIT}{1,2})"
      HEX16 = "\\$?(#{HEX_DIGIT}{1,4})"

      SINGLE_OPERAND_INSTRUCTIONS = %i[imp imm4 rn rm rel lnk].freeze
      DOUBLE_OPERAND_INSTRUCTIONS = %i[rn_rn rn_imm8 rn_imm16 rn_addr rn_addrl addr_rn addrl_rn].freeze
      REL_INSTRUCTIONS = %i[rel].freeze
      BIT_INSTRUCTIONS = %i[].freeze
      SFX_INSTRUCTIONS = %i[imm4 rn rm rn_rn rn_imm8 rn_imm16 rn_addr rn_addrl addr_rn addrl_rn].freeze
      MOV_INSTRUCTIONS = %i[rn_rn]
      SHORT_ADDR_INSTRUCTIONS = %i[rn_addr addr_rn]
      INV_DEST_INSTRUCTIONS = %i[addr_rn addrl_rn]

      MODES_REGEXES = {
        imp: /^$/,             # nothing
        imm4: /^##{HEX}$/,     # #0-f
        lnk: /^##{LNK}$/,      # #1-4
        rn: /^#{REG}$/,        # R1
        rm: /^\(#{REG}\)$/,    # (R1)
        rel: /^#{HEX16}$/i,    # label / 1234
        rn_rn: /^#{REG},#{REG}$/,          # R1, R2
        rn_imm8: /^#{REG},##{HEX8}$/,      # R1, #12
        rn_imm16: /^#{REG},##{HEX16}$/,    # R1, #1234
        rn_addr: /^#{REG},\(#{HEX16}\)$/,   # R1, (1234) ; -> actual data is 1234 / 2
        rn_addrl: /^#{REG},\(#{HEX16}\)$/, # R1, (1234) ; label
        addr_rn: /^\(#{HEX16}\),#{REG}$/,   # (1234), R1 ; -> actual data is 1234 / 2
        addrl_rn: /^\(#{HEX16}\),#{REG}$/, # (1234), R1 ; label
      }.freeze

      OPCODES_DATA = [
                      # From game pak ROM to register
                      { opcode: 0xef, mnemonic: 'GETB',  mode: :imp, length: 1, alt: nil },
                      { opcode: 0xef, mnemonic: 'GETBH', mode: :imp, length: 2, alt: 0x3d },
                      { opcode: 0xef, mnemonic: 'GETBL', mode: :imp, length: 2, alt: 0x3e },
                      { opcode: 0xef, mnemonic: 'GETBS', mode: :imp, length: 2, alt: 0x3f },
                      { opcode: 0xdf, mnemonic: 'GETC',  mode: :imp, length: 1, alt: nil },

                      # From game pak RAM to register
                      { opcode: 0x4,  mnemonic: 'LDW',   mode: :rm, length: 1, alt: nil },
                      { opcode: 0x4,  mnemonic: 'LDB',   mode: :rm, length: 1, alt: 0x3d },
                      { opcode: 0xf,  mnemonic: 'LM',    mode: :rn_addrl, length: 4, alt: 0x3d },
                      { opcode: 0xa,  mnemonic: 'LMS',   mode: :rn_addr, length: 3, alt: 0x3d },

                      # From register to game pak RAM
                      { opcode: 0x3,  mnemonic: 'STW',   mode: :rm, length: 1, alt: nil },
                      { opcode: 0x3,  mnemonic: 'STB',   mode: :rm, length: 2, alt: 0x3d },
                      { opcode: 0xf,  mnemonic: 'SM',    mode: :addrl_rn, length: 4, alt: 0x3e },
                      { opcode: 0xa,  mnemonic: 'SMS',   mode: :addr_rn, length: 3, alt: 0x3e },
                      { opcode: 0x90, mnemonic: 'SBK',   mode: :imp, length: 1, alt: nil },

                      # From register to register
                      { opcode: 0x2010, mnemonic: 'MOVE', mode: :rn_rn, length: 2, alt: nil },
                      { opcode: 0x20b0, mnemonic: 'MOVES', mode: :rn_rn, length: 2, alt: nil },

                      # Immediate data to register
                      { opcode: 0xf,  mnemonic: 'IWT',   mode: :rn_imm16, length: 3, alt: nil },
                      { opcode: 0xa,  mnemonic: 'IBT',   mode: :rn_imm8, length: 2, alt: nil },

                      # Arithmetic operations
                      { opcode: 0x5,  mnemonic: 'ADD',   mode: :rn, length: 1, alt: nil },
                      { opcode: 0x5,  mnemonic: 'ADD',   mode: :imm4, length: 2, alt: 0x3e },
                      { opcode: 0x5,  mnemonic: 'ADC',   mode: :rn, length: 2, alt: 0x3d },
                      { opcode: 0x5,  mnemonic: 'ADC',   mode: :imm4, length: 2, alt: 0x3f },

                      { opcode: 0x6,  mnemonic: 'SUB',   mode: :rn, length: 1, alt: nil },
                      { opcode: 0x6,  mnemonic: 'SUB',   mode: :imm4, length: 2, alt: 0x3e },
                      { opcode: 0x6,  mnemonic: 'SBC',   mode: :rn, length: 2, alt: 0x3d },

                      { opcode: 0x6,  mnemonic: 'CMP',   mode: :rn, length: 2, alt: 0x3f },

                      { opcode: 0x8,  mnemonic: 'MULT',  mode: :rn, length: 1, alt: nil },
                      { opcode: 0x8,  mnemonic: 'MULT',  mode: :imm4, length: 2, alt: 0x3e },
                      { opcode: 0x8,  mnemonic: 'UMULT', mode: :rn, length: 2, alt: 0x3d },
                      { opcode: 0x8,  mnemonic: 'UMULT', mode: :imm4, length: 2, alt: 0x3f },
                      { opcode: 0x9f, mnemonic: 'FMULT', mode: :imp, length: 1, alt: nil },
                      { opcode: 0x9f, mnemonic: 'LMULT', mode: :imp, length: 2, alt: 0x3d },

                      { opcode: 0x96, mnemonic: 'DIV2',  mode: :imp, length: 2, alt: 0x3d },

                      { opcode: 0xd,  mnemonic: 'INC',   mode: :rn, length: 1, alt: nil },
                      { opcode: 0xe,  mnemonic: 'DEC',   mode: :rn, length: 1, alt: nil },

                      # Logical operations
                      { opcode: 0x7,  mnemonic: 'AND',   mode: :rn, length: 1, alt: nil },
                      { opcode: 0x7,  mnemonic: 'AND',   mode: :imm4, length: 2, alt: 0x3e },
                      { opcode: 0xc,  mnemonic: 'OR',    mode: :rn, length: 1, alt: nil },
                      { opcode: 0xc,  mnemonic: 'OR',    mode: :imm4, length: 2, alt: 0x3e },
                      { opcode: 0x4f, mnemonic: 'NOT',   mode: :imp, length: 1, alt: nil },
                      { opcode: 0xc,  mnemonic: 'XOR',   mode: :rn, length: 2, alt: 0x3d },
                      { opcode: 0xc,  mnemonic: 'XOR',   mode: :imm4, length: 2, alt: 0x3f },
                      { opcode: 0x7,  mnemonic: 'BIC',   mode: :rn, length: 2, alt: 0x3d },
                      { opcode: 0x7,  mnemonic: 'BIC',   mode: :imm4, length: 2, alt: 0x3f },

                      # Shift
                      { opcode: 0x96, mnemonic: 'ASR',   mode: :imp, length: 1, alt: nil },
                      { opcode: 0x03, mnemonic: 'LSR',   mode: :imp, length: 1, alt: nil },
                      { opcode: 0x04, mnemonic: 'ROL',   mode: :imp, length: 1, alt: nil },
                      { opcode: 0x97, mnemonic: 'ROR',   mode: :imp, length: 1, alt: nil },

                      # Byte transfer
                      { opcode: 0xc0, mnemonic: 'HIB',   mode: :imp, length: 1, alt: nil },
                      { opcode: 0x9e, mnemonic: 'LOB',   mode: :imp, length: 1, alt: nil },
                      { opcode: 0x70, mnemonic: 'MERGE', mode: :imp, length: 1, alt: nil },
                      { opcode: 0x95, mnemonic: 'SEX',   mode: :imp, length: 1, alt: nil },
                      { opcode: 0x4d, mnemonic: 'SWAP',  mode: :imp, length: 1, alt: nil },

                      # Jump, branch and loop
                      { opcode: 0x9,  mnemonic: 'JMP',   mode: :rn, length: 1, alt: nil },
                      { opcode: 0x9,  mnemonic: 'LJMP',  mode: :rn, length: 2, alt: 0x3d },
                      { opcode: 0x05, mnemonic: 'BRA',   mode: :rel, length: 2, alt: nil },
                      { opcode: 0x06, mnemonic: 'BLT',   mode: :rel, length: 2, alt: nil },
                      { opcode: 0x07, mnemonic: 'BGE',   mode: :rel, length: 2, alt: nil },
                      { opcode: 0x08, mnemonic: 'BNE',   mode: :rel, length: 2, alt: nil },
                      { opcode: 0x09, mnemonic: 'BEQ',   mode: :rel, length: 2, alt: nil },
                      { opcode: 0x0a, mnemonic: 'BPL',   mode: :rel, length: 2, alt: nil },
                      { opcode: 0x0b, mnemonic: 'BMI',   mode: :rel, length: 2, alt: nil },
                      { opcode: 0x0c, mnemonic: 'BCC',   mode: :rel, length: 2, alt: nil },
                      { opcode: 0x0d, mnemonic: 'BCS',   mode: :rel, length: 2, alt: nil },
                      { opcode: 0x0e, mnemonic: 'BVC',   mode: :rel, length: 2, alt: nil },
                      { opcode: 0x0f, mnemonic: 'BVS',   mode: :rel, length: 2, alt: nil },
                      { opcode: 0x3c, mnemonic: 'LOOP',  mode: :imp, length: 1, alt: nil },
                      { opcode: 0x9,  mnemonic: 'LINK',  mode: :imm4, length: 1, alt: nil },

                      # Bank set-up
                      { opcode: 0xdf, mnemonic: 'ROMB',  mode: :imp, length: 2, alt: 0x3f },
                      { opcode: 0xdf, mnemonic: 'RAMB',  mode: :imp, length: 2, alt: 0x3e },

                      # Plot related
                      { opcode: 0x4e, mnemonic: 'CMODE', mode: :imp, length: 2, alt: 0x3d },
                      { opcode: 0x4e, mnemonic: 'COLOR', mode: :imp, length: 1, alt: nil },
                      { opcode: 0x4c, mnemonic: 'PLOT',  mode: :imp, length: 1, alt: nil },
                      { opcode: 0x4c, mnemonic: 'RPIX',  mode: :imp, length: 2, alt: 0x3d },

                      # Prefix flag
                      { opcode: 0x3d, mnemonic: 'ALT1',  mode: :imp, length: 1, alt: nil },
                      { opcode: 0x3e, mnemonic: 'ALT2',  mode: :imp, length: 1, alt: nil },
                      { opcode: 0x3f, mnemonic: 'ALT3',  mode: :imp, length: 1, alt: nil },

                      # Prefix register
                      { opcode: 0xb,  mnemonic: 'FROM',  mode: :rn, length: 1, alt: nil },
                      { opcode: 0x1,  mnemonic: 'TO',    mode: :rn, length: 1, alt: nil },
                      { opcode: 0x2,  mnemonic: 'WITH',  mode: :rn, length: 1, alt: nil },

                      # GSU Control
                      { opcode: 0x02, mnemonic: 'CACHE', mode: :imp, length: 1, alt: nil },
                      { opcode: 0x01, mnemonic: 'NOP',   mode: :imp, length: 1, alt: nil },
                      { opcode: 0x00, mnemonic: 'STOP',  mode: :imp, length: 1, alt: nil }].freeze
    end
  end
end
