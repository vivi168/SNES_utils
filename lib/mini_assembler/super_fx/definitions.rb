# frozen_string_literal: true

module SnesUtils
  module SuperFx
    class Definitions
      HEX_DIGIT = '[0-9a-f]'
      REG   = "[rR](\d{1,2})"
      LNK   = "([1-4])"
      HEX   = "\\$?(#{HEX_DIGIT})"
      HEX8  = "\\$?(#{HEX_DIGIT}{1,2})"
      HEX16 = "\\$?(#{HEX_DIGIT}{3,4})"

      SINGLE_OPERAND_INSTRUCTIONS = %i[imp imm4 rn rm rel lnk].freeze
      DOUBLE_OPERAND_INSTRUCTIONS = %i[rn_rn rn_imm8 rn_imm16 rn_addr rn_addrl].freeze
      REL_INSTRUCTIONS = %i[rel].freeze
      BIT_INSTRUCTIONS = %i[].freeze
      ALT_INSTRUCTIONS = %i[adc add and bic cmode cmp div2 getbh getbl getbs ldb ljmp lm lms lmult mult or ramb romb rpix sbc sm sms stb sub umult xor].freeze

      MODES_REGEXES = {
        imp: /^$/,             # nothing
        imm4: /^##{HEX}$/,     # 0-f
        rn: /^#{REG}$/         # R1
        rm: /^\(#{REG}\)$/     # (R1)
        rel: /^#{HEX16}$/i,    # label / 1234
        lnk: /^\(#{LNK}\)$/    # #1
        rn_rn: /^#{REG},#{REG}$/           # R1, R2
        rn_imm8: /^#{REG},##{HEX8}$/,      # R1, #12
        rn_imm16: /^#{REG},##{HEX16}$/,    # R1, #1234
        rn_addr: /^#{REG},\(#{HEX8}\)$/,   # R1, (12) ; -> actual data is 12 / 2
        rn_addrl: /^#{REG},\(#{HEX16}\)$/, # R1, (1234) ; label
      }.freeze

      OPCODES_DATA = [
                      { opcode: 0x5,  mnemonic: 'ADC',   mode: :rn, length: 2, alt: 0x3d }
                      { opcode: 0x5,  mnemonic: 'ADC',   mode: :imm4, length: 2, alt: 0x3f }
                      { opcode: 0x5,  mnemonic: 'ADD',   mode: :rn, length: 1, alt: 0 }
                      { opcode: 0x5,  mnemonic: 'ADD',   mode: :imm4, length: 2, alt: 0x3e }
                      { opcode: 0x3d, mnemonic: 'ALT1',  mode: :imp, length: 1, alt: 0 }
                      { opcode: 0x3e, mnemonic: 'ALT2',  mode: :imp, length: 1, alt: 0 }
                      { opcode: 0x3f, mnemonic: 'ALT3',  mode: :imp, length: 1, alt: 0 }
                      { opcode: 0x7,  mnemonic: 'AND',   mode: :rn, length: 1, alt: 0 }
                      { opcode: 0x7,  mnemonic: 'AND',   mode: :imm4, length: 2, alt: 0x3e }
                      { opcode: 0x96, mnemonic: 'ASR',   mode: :imp, length: 1, alt: 0 }
                      { opcode: 0x0c, mnemonic: 'BCC',   mode: :rel, length: 2, alt: 0 }
                      { opcode: 0x0d, mnemonic: 'BCS',   mode: :rel, length: 2, alt: 0 }
                      { opcode: 0x09, mnemonic: 'BEQ',   mode: :rel, length: 2, alt: 0 }
                      { opcode: 0x06, mnemonic: 'BGE',   mode: :rel, length: 2, alt: 0 }
                      { opcode: 0x7,  mnemonic: 'BIC',   mode: :rn, length: 2, alt: 0x3d }
                      { opcode: 0x7,  mnemonic: 'BIC',   mode: :imm4, length: 2, alt: 0x3f }
                      { opcode: 0x07, mnemonic: 'BLT',   mode: :rel, length: 2, alt: 0 }
                      { opcode: 0x0b, mnemonic: 'BMI',   mode: :rel, length: 2, alt: 0 }
                      { opcode: 0x08, mnemonic: 'BNE',   mode: :rel, length: 2, alt: 0 }
                      { opcode: 0x0a, mnemonic: 'BPL',   mode: :rel, length: 2, alt: 0 }
                      { opcode: 0x05, mnemonic: 'BRA',   mode: :rel, length: 2, alt: 0 }
                      { opcode: 0x0e, mnemonic: 'BVC',   mode: :rel, length: 2, alt: 0 }
                      { opcode: 0x0f, mnemonic: 'BVS',   mode: :rel, length: 2, alt: 0 }
                      { opcode: 0x02, mnemonic: 'CACHE', mode: :imp, length: 1, alt: 0 }
                      { opcode: 0x4e, mnemonic: 'CMODE', mode: :imp, length: 2, alt: 0x3d }
                      { opcode: 0x6,  mnemonic: 'CMP',   mode: :rn, length: 2, alt: 0x3f }
                      { opcode: 0x4e, mnemonic: 'COLOR', mode: :imp, length: 1, alt: 0 }
                      { opcode: 0xe,  mnemonic: 'DEC',   mode: :rn, length: 1, alt: 0 }
                      { opcode: 0x96, mnemonic: 'DIV2',  mode: :imp, length: 2, alt: 0x3d }
                      { opcode: 0x9f, mnemonic: 'FMULT', mode: :imp, length: 1, alt: 0 }
                      { opcode: 0xb,  mnemonic: 'FROM',  mode: :rn, length: 1, alt: 0 }
                      { opcode: 0xef, mnemonic: 'GETB',  mode: :imp, length: 1, alt: 0 }
                      { opcode: 0xef, mnemonic: 'GETBH', mode: :imp, length: 2, alt: 0x3d }
                      { opcode: 0xef, mnemonic: 'GETBL', mode: :imp, length: 2, alt: 0x3e }
                      { opcode: 0xef, mnemonic: 'GETBS', mode: :imp, length: 2, alt: 0x3f }
                      { opcode: 0xdf, mnemonic: 'GETC',  mode: :imp, length: 1, alt: 0 }
                      { opcode: 0xc0, mnemonic: 'HIB',   mode: :imp, length: 1, alt: 0 }
                      { opcode: 0xa,  mnemonic: 'IBT',   mode: :rn_imm8, length: 2, alt: 0 }
                      { opcode: 0xd,  mnemonic: 'INC',   mode: :rn, length: 1, alt: 0 }
                      { opcode: 0xf,  mnemonic: 'IWT',   mode: :rn_imm16, length: 3, alt: 0 }
                      { opcode: 0x9,  mnemonic: 'JMP',   mode: :rn, length: 1, alt: 0 }
                      { opcode: 0x4,  mnemonic: 'LDB',   mode: :rm, length: 1, alt: 0x3d }
                      { opcode: 0x4,  mnemonic: 'LDW',   mode: :rm, length: 1, alt: 0 }
                      { opcode: 0xf,  mnemonic: 'LEA',   mode: :rn_addrl, length: 3, alt: 0 }
                      { opcode: 0x9,  mnemonic: 'LINK',  mode: :imm4, length: 1, alt: 0 }
                      { opcode: 0x9,  mnemonic: 'LJMP',  mode: :rn, length: 2, alt: 0x3d }
                      { opcode: 0xf,  mnemonic: 'LM',    mode: :rn_addrl, length: 2, alt: 0x3d }
                      { opcode: 0xa,  mnemonic: 'LMS',   mode: :rn_addr, length: 2, alt: 0x3d }
                      { opcode: 0x9f, mnemonic: 'LMULT', mode: :imp, length: 2, alt: 0x3d }
                      { opcode: 0x9e, mnemonic: 'LOB',   mode: :imp, length: 1, alt: 0 }
                      { opcode: 0x3c, mnemonic: 'LOOP',  mode: :imp, length: 1, alt: 0 }
                      { opcode: 0x03, mnemonic: 'LSR',   mode: :imp, length: 1, alt: 0 }
                      { opcode: 0x70, mnemonic: 'MERGE', mode: :imp, length: 1, alt: 0 }
                      { opcode: '0x2?1?', mnemonic: 'MOVE', mode: :rn_rn, length: 2, alt: 0 }
                      { opcode: '0x2?b?', mnemonic: 'MOVES', mode: :rn_rn, length: 2, alt: 0 }
                      { opcode: 0x8,  mnemonic: 'MULT',  mode: :rn, length: 1, alt: 0 }
                      { opcode: 0x8,  mnemonic: 'MULT',  mode: :imm4, length: 2, alt: 0x3e }
                      { opcode: 0x01, mnemonic: 'NOP',   mode: :imp, length: 1, alt: 0 }
                      { opcode: 0x4f, mnemonic: 'NOT',   mode: :imp, length: 1, alt: 0 }
                      { opcode: 0xc,  mnemonic: 'OR',    mode: :rn, length: 1, alt: 0 }
                      { opcode: 0xc,  mnemonic: 'OR',    mode: :imm4, length: 2, alt: 0x3e }
                      { opcode: 0x4c, mnemonic: 'PLOT',  mode: :imp, length: 1, alt: 0 }
                      { opcode: 0xdf, mnemonic: 'RAMB',  mode: :imp, length: 2, alt: 0x3e }
                      { opcode: 0x04, mnemonic: 'ROL',   mode: :imp, length: 1, alt: 0 }
                      { opcode: 0xdf, mnemonic: 'ROMB',  mode: :imp, length: 2, alt: 0x3f }
                      { opcode: 0x97, mnemonic: 'ROR',   mode: :imp, length: 1, alt: 0 }
                      { opcode: 0x4c, mnemonic: 'RPIX',  mode: :imp, length: 2, alt: 0x3d }
                      { opcode: 0x6,  mnemonic: 'SBC',   mode: :rn, length: 2, alt: 0x3d }
                      { opcode: 0x9,  mnemonic: 'SBK',   mode: :imp, length: 1, alt: 0 }
                      { opcode: 0x95, mnemonic: 'SEX',   mode: :imp, length: 1, alt: 0 }
                      { opcode: 0xf,  mnemonic: 'SM',    mode: :rn_addrl, length: 3, alt: 0x3e }
                      { opcode: 0xa,  mnemonic: 'SMS',   mode: :rn_addr, length: 3, alt: 0x3e }
                      { opcode: 0x3,  mnemonic: 'STB',   mode: :rm, length: 2, alt: 0x3d }
                      { opcode: 0x00, mnemonic: 'STOP',  mode: :imp, length: 1, alt: 0 }
                      { opcode: 0x3,  mnemonic: 'STW',   mode: :rm, length: 1, alt: 0 }
                      { opcode: 0x6,  mnemonic: 'SUB',   mode: :rn, length: 1, alt: 0 }
                      { opcode: 0x6,  mnemonic: 'SUB',   mode: :imm4, length: 2, alt: 0x3e }
                      { opcode: 0x4d, mnemonic: 'SWAP',  mode: :imp, length: 1, alt: 0 }
                      { opcode: 0x1,  mnemonic: 'TO',    mode: :rn, length: 1, alt: 0 }
                      { opcode: 0x8,  mnemonic: 'UMULT', mode: :rn, length: 2, alt: 0x3d }
                      { opcode: 0x8,  mnemonic: 'UMULT', mode: :imm4, length: 2, alt: 0x3f }
                      { opcode: 0x2,  mnemonic: 'WITH',  mode: :rn, length: 1, alt: 0 }
                      { opcode: 0xc,  mnemonic: 'XOR',   mode: :rn, length: 2, alt: 0x3d }
                      { opcode: 0xc,  mnemonic: 'XOR',   mode: :imm4, length: 2, alt: 0x3f }].freeze
    end
  end
end
