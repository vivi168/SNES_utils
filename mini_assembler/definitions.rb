module Definitions
  HEX_DIGIT = '[0-9a-f]'
  HEX8  = "\\$?(#{HEX_DIGIT}{1,2})"
  HEX16 = "\\$?(#{HEX_DIGIT}{3,4})"
  HEX24 = "\\$?(#{HEX_DIGIT}{5,6})"

  MODES_REGEXES = {
    acc:   /^$/,
    imp:   /^$/,
    imm:   /^#{HEX8}$/i,
    iml:   /^#{HEX16}$/i,
    imm8:  /^##{HEX8}$/i,
    imm16: /^##{HEX16}$/i,
    sr:    /^#{HEX8},S$/i,
    dp:    /^#{HEX8}$/i,
    dpx:   /^#{HEX8},X$/i,
    dpy:   /^#{HEX8},Y$/i,
    idp:   /^\(#{HEX8}\)$/i,
    idx:   /^\(#{HEX8},X\)$/i,
    idy:   /^\(#{HEX8}\),Y$/i,
    idl:   /^\[#{HEX8}\]$/i,
    idly:  /^\[#{HEX8}\],Y$/i,
    isy:   /^\(#{HEX8},S\),Y$/i,
    abs:   /^#{HEX16}$/i,
    abx:   /^#{HEX16},X$/i,
    aby:   /^#{HEX16},Y$/i,
    abl:   /^#{HEX24}$/i,
    alx:   /^#{HEX24},X$/i,
    ind:   /^\(#{HEX16}\)$/i,
    iax:   /^\(#{HEX16},X\)$/i,
    ial:   /^\[#{HEX16}\]$/i,
    rel:   /^#{HEX16}$/i,
    rell:  /^#{HEX16}$/i,
    bm:    /^#{HEX8},#{HEX8}$/i
  }

  BYTE_LOC_REGEX = /^#{HEX_DIGIT}{1,4}$/i
  BYTE_RANGE_REGEX = /^(#{HEX_DIGIT}{1,4})\.+(#{HEX_DIGIT}{1,4})$/i
  BYTE_SEQUENCE_REGEX = /^(#{HEX_DIGIT}{1,4}):\s*([0-9a-f ]+)$/i
  DISASSEMBLE_REGEX = /^(#{HEX_DIGIT}{,4})l/i
  SWITCH_BANK_REGEX = /^(#{HEX_DIGIT}{1,2})\/$/i
  FLIP_MX_REG_REGEX = /^([01])=([xm])$/i
  WRITE_REGEX = /^\.write\s*(.*)$/i
  INCBIN_REGEX = /^(#{HEX_DIGIT}{1,4}):\s*\.incbin\s+(.*)$/i

  MODES_FORMATS = {
    acc:   "%s",
    imp:   "%s",
    imm:   "%s #%02X",
    iml:   "%s %02X",
    imm8:  "%s #%02X",
    imm16: "%s #%04X",
    sr:    "%s #%02X,S",
    dp:    "%s %02X",
    dpx:   "%s %02X,X",
    dpy:   "%s %02X,Y",
    idp:   "%s (%02X)",
    idx:   "%s (%02X,X)",
    idy:   "%s (%02X),Y",
    idl:   "%s [%02X]",
    idly:  "%s [%02X],Y",
    isy:   "%s (%02X,S),Y",
    abs:   "%s %04X",
    abx:   "%s %04X,X",
    aby:   "%s %04X,Y",
    abl:   "%s %06x",
    alx:   "%s %06x,X",
    ind:   "%s (%04X)",
    iax:   "%s (%04X,X)",
    ial:   "%s [%04X]",
    rel:   "%s %04X {%s}",
    rell:  "%s %04X {%s}",
    bm:    "%s %02X,%02X"
  }

  OPCODES_DATA = [{ opcode: 0x61, mnemonic: 'ADC', mode: :idx, length: 2, m: nil, x: nil },
                  { opcode: 0x63, mnemonic: 'ADC', mode: :sr, length: 2, m: nil, x: nil },
                  { opcode: 0x65, mnemonic: 'ADC', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x67, mnemonic: 'ADC', mode: :idl, length: 2, m: nil, x: nil },
                  { opcode: 0x69, mnemonic: 'ADC', mode: :imm8, length: 2, m: 1, x: nil },
                  { opcode: 0x69, mnemonic: 'ADC', mode: :imm16, length: 3, m: 0, x: nil },
                  { opcode: 0x6d, mnemonic: 'ADC', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x6f, mnemonic: 'ADC', mode: :abl, length: 4, m: nil, x: nil },
                  { opcode: 0x71, mnemonic: 'ADC', mode: :idy, length: 2, m: nil, x: nil },
                  { opcode: 0x72, mnemonic: 'ADC', mode: :idp, length: 2, m: nil, x: nil },
                  { opcode: 0x73, mnemonic: 'ADC', mode: :isy, length: 2, m: nil, x: nil },
                  { opcode: 0x75, mnemonic: 'ADC', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0x77, mnemonic: 'ADC', mode: :idly, length: 2, m: nil, x: nil },
                  { opcode: 0x79, mnemonic: 'ADC', mode: :aby, length: 3, m: nil, x: nil },
                  { opcode: 0x7d, mnemonic: 'ADC', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0x7f, mnemonic: 'ADC', mode: :alx, length: 4, m: nil, x: nil },
                  { opcode: 0xe1, mnemonic: 'SBC', mode: :idx, length: 2, m: nil, x: nil },
                  { opcode: 0xe3, mnemonic: 'SBC', mode: :sr, length: 2, m: nil, x: nil },
                  { opcode: 0xe5, mnemonic: 'SBC', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0xe7, mnemonic: 'SBC', mode: :idl, length: 2, m: nil, x: nil },
                  { opcode: 0xe9, mnemonic: 'SBC', mode: :imm8, length: 2, m: 1, x: nil },
                  { opcode: 0xe9, mnemonic: 'SBC', mode: :imm16, length: 3, m: 0, x: nil },
                  { opcode: 0xed, mnemonic: 'SBC', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0xef, mnemonic: 'SBC', mode: :abl, length: 4, m: nil, x: nil },
                  { opcode: 0xf1, mnemonic: 'SBC', mode: :idy, length: 2, m: nil, x: nil },
                  { opcode: 0xf2, mnemonic: 'SBC', mode: :idp, length: 2, m: nil, x: nil },
                  { opcode: 0xf3, mnemonic: 'SBC', mode: :isy, length: 2, m: nil, x: nil },
                  { opcode: 0xf5, mnemonic: 'SBC', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0xf7, mnemonic: 'SBC', mode: :idly, length: 2, m: nil, x: nil },
                  { opcode: 0xf9, mnemonic: 'SBC', mode: :aby, length: 3, m: nil, x: nil },
                  { opcode: 0xfd, mnemonic: 'SBC', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0xff, mnemonic: 'SBC', mode: :alx, length: 4, m: nil, x: nil },
                  { opcode: 0xc1, mnemonic: 'CMP', mode: :idx, length: 2, m: nil, x: nil },
                  { opcode: 0xc3, mnemonic: 'CMP', mode: :sr, length: 2, m: nil, x: nil },
                  { opcode: 0xc5, mnemonic: 'CMP', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0xc7, mnemonic: 'CMP', mode: :idl, length: 2, m: nil, x: nil },
                  { opcode: 0xc9, mnemonic: 'CMP', mode: :imm8, length: 2, m: 1, x: nil },
                  { opcode: 0xc9, mnemonic: 'CMP', mode: :imm16, length: 3, m: 0, x: nil },
                  { opcode: 0xcd, mnemonic: 'CMP', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0xcf, mnemonic: 'CMP', mode: :abl, length: 4, m: nil, x: nil },
                  { opcode: 0xd1, mnemonic: 'CMP', mode: :idy, length: 2, m: nil, x: nil },
                  { opcode: 0xd2, mnemonic: 'CMP', mode: :idp, length: 2, m: nil, x: nil },
                  { opcode: 0xd3, mnemonic: 'CMP', mode: :isy, length: 2, m: nil, x: nil },
                  { opcode: 0xd5, mnemonic: 'CMP', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0xd7, mnemonic: 'CMP', mode: :idly, length: 2, m: nil, x: nil },
                  { opcode: 0xd9, mnemonic: 'CMP', mode: :aby, length: 3, m: nil, x: nil },
                  { opcode: 0xdd, mnemonic: 'CMP', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0xdf, mnemonic: 'CMP', mode: :alx, length: 4, m: nil, x: nil },
                  { opcode: 0xe0, mnemonic: 'CPX', mode: :imm8, length: 2, m: nil, x: 1 },
                  { opcode: 0xe0, mnemonic: 'CPX', mode: :imm16, length: 3, m: nil, x: 0 },
                  { opcode: 0xe4, mnemonic: 'CPX', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0xec, mnemonic: 'CPX', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0xc0, mnemonic: 'CPY', mode: :imm8, length: 2, m: nil, x: 1 },
                  { opcode: 0xc0, mnemonic: 'CPY', mode: :imm16, length: 3, m: nil, x: 0 },
                  { opcode: 0xc4, mnemonic: 'CPY', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0xcc, mnemonic: 'CPY', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x3a, mnemonic: 'DEC', mode: :acc, length: 1, m: nil, x: nil },
                  { opcode: 0xc6, mnemonic: 'DEC', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0xce, mnemonic: 'DEC', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0xd6, mnemonic: 'DEC', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0xde, mnemonic: 'DEC', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0xca, mnemonic: 'DEX', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x88, mnemonic: 'DEY', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x1a, mnemonic: 'INC', mode: :acc, length: 1, m: nil, x: nil },
                  { opcode: 0xe6, mnemonic: 'INC', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0xee, mnemonic: 'INC', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0xf6, mnemonic: 'INC', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0xfe, mnemonic: 'INC', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0xe8, mnemonic: 'INX', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xc8, mnemonic: 'INY', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x21, mnemonic: 'AND', mode: :idx, length: 2, m: nil, x: nil },
                  { opcode: 0x23, mnemonic: 'AND', mode: :sr, length: 2, m: nil, x: nil },
                  { opcode: 0x25, mnemonic: 'AND', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x27, mnemonic: 'AND', mode: :idl, length: 2, m: nil, x: nil },
                  { opcode: 0x29, mnemonic: 'AND', mode: :imm8, length: 2, m: 1, x: nil },
                  { opcode: 0x29, mnemonic: 'AND', mode: :imm16, length: 3, m: 0, x: nil },
                  { opcode: 0x2d, mnemonic: 'AND', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x2f, mnemonic: 'AND', mode: :abl, length: 4, m: nil, x: nil },
                  { opcode: 0x31, mnemonic: 'AND', mode: :idy, length: 2, m: nil, x: nil },
                  { opcode: 0x32, mnemonic: 'AND', mode: :idp, length: 2, m: nil, x: nil },
                  { opcode: 0x33, mnemonic: 'AND', mode: :isy, length: 2, m: nil, x: nil },
                  { opcode: 0x35, mnemonic: 'AND', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0x37, mnemonic: 'AND', mode: :idly, length: 2, m: nil, x: nil },
                  { opcode: 0x39, mnemonic: 'AND', mode: :aby, length: 3, m: nil, x: nil },
                  { opcode: 0x3d, mnemonic: 'AND', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0x3f, mnemonic: 'AND', mode: :alx, length: 4, m: nil, x: nil },
                  { opcode: 0x41, mnemonic: 'EOR', mode: :idx, length: 2, m: nil, x: nil },
                  { opcode: 0x43, mnemonic: 'EOR', mode: :sr, length: 2, m: nil, x: nil },
                  { opcode: 0x45, mnemonic: 'EOR', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x47, mnemonic: 'EOR', mode: :idl, length: 2, m: nil, x: nil },
                  { opcode: 0x49, mnemonic: 'EOR', mode: :imm8, length: 2, m: 1, x: nil },
                  { opcode: 0x49, mnemonic: 'EOR', mode: :imm16, length: 3, m: 0, x: nil },
                  { opcode: 0x4d, mnemonic: 'EOR', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x4f, mnemonic: 'EOR', mode: :abl, length: 4, m: nil, x: nil },
                  { opcode: 0x51, mnemonic: 'EOR', mode: :idy, length: 2, m: nil, x: nil },
                  { opcode: 0x52, mnemonic: 'EOR', mode: :idp, length: 2, m: nil, x: nil },
                  { opcode: 0x53, mnemonic: 'EOR', mode: :isy, length: 2, m: nil, x: nil },
                  { opcode: 0x55, mnemonic: 'EOR', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0x57, mnemonic: 'EOR', mode: :idly, length: 2, m: nil, x: nil },
                  { opcode: 0x59, mnemonic: 'EOR', mode: :aby, length: 3, m: nil, x: nil },
                  { opcode: 0x5d, mnemonic: 'EOR', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0x5f, mnemonic: 'EOR', mode: :alx, length: 4, m: nil, x: nil },
                  { opcode: 0x01, mnemonic: 'ORA', mode: :idx, length: 2, m: nil, x: nil },
                  { opcode: 0x03, mnemonic: 'ORA', mode: :sr, length: 2, m: nil, x: nil },
                  { opcode: 0x05, mnemonic: 'ORA', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x07, mnemonic: 'ORA', mode: :idl, length: 2, m: nil, x: nil },
                  { opcode: 0x09, mnemonic: 'ORA', mode: :imm8, length: 2, m: 1, x: nil },
                  { opcode: 0x09, mnemonic: 'ORA', mode: :imm16, length: 3, m: 0, x: nil },
                  { opcode: 0x0d, mnemonic: 'ORA', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x0f, mnemonic: 'ORA', mode: :abl, length: 4, m: nil, x: nil },
                  { opcode: 0x11, mnemonic: 'ORA', mode: :idy, length: 2, m: nil, x: nil },
                  { opcode: 0x12, mnemonic: 'ORA', mode: :idp, length: 2, m: nil, x: nil },
                  { opcode: 0x13, mnemonic: 'ORA', mode: :isy, length: 2, m: nil, x: nil },
                  { opcode: 0x15, mnemonic: 'ORA', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0x17, mnemonic: 'ORA', mode: :idly, length: 2, m: nil, x: nil },
                  { opcode: 0x19, mnemonic: 'ORA', mode: :aby, length: 3, m: nil, x: nil },
                  { opcode: 0x1d, mnemonic: 'ORA', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0x1f, mnemonic: 'ORA', mode: :alx, length: 4, m: nil, x: nil },
                  { opcode: 0x24, mnemonic: 'BIT', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x2c, mnemonic: 'BIT', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x34, mnemonic: 'BIT', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0x3c, mnemonic: 'BIT', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0x89, mnemonic: 'BIT', mode: :imm8, length: 2, m: 1, x: nil },
                  { opcode: 0x89, mnemonic: 'BIT', mode: :imm16, length: 3, m: 0, x: nil },
                  { opcode: 0x14, mnemonic: 'TRB', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x1c, mnemonic: 'TRB', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x04, mnemonic: 'TSB', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x0c, mnemonic: 'TSB', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x06, mnemonic: 'ASL', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x0a, mnemonic: 'ASL', mode: :acc, length: 1, m: nil, x: nil },
                  { opcode: 0x0e, mnemonic: 'ASL', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x16, mnemonic: 'ASL', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0x1e, mnemonic: 'ASL', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0x46, mnemonic: 'LSR', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x4a, mnemonic: 'LSR', mode: :acc, length: 1, m: nil, x: nil },
                  { opcode: 0x4e, mnemonic: 'LSR', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x56, mnemonic: 'LSR', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0x5e, mnemonic: 'LSR', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0x26, mnemonic: 'ROL', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x2a, mnemonic: 'ROL', mode: :acc, length: 1, m: nil, x: nil },
                  { opcode: 0x2e, mnemonic: 'ROL', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x36, mnemonic: 'ROL', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0x3e, mnemonic: 'ROL', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0x66, mnemonic: 'ROR', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x6a, mnemonic: 'ROR', mode: :acc, length: 1, m: nil, x: nil },
                  { opcode: 0x6e, mnemonic: 'ROR', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x76, mnemonic: 'ROR', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0x7e, mnemonic: 'ROR', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0x90, mnemonic: 'BCC', mode: :rel, length: 2, m: nil, x: nil },
                  { opcode: 0xb0, mnemonic: 'BCS', mode: :rel, length: 2, m: nil, x: nil },
                  { opcode: 0xf0, mnemonic: 'BEQ', mode: :rel, length: 2, m: nil, x: nil },
                  { opcode: 0x30, mnemonic: 'BMI', mode: :rel, length: 2, m: nil, x: nil },
                  { opcode: 0xd0, mnemonic: 'BNE', mode: :rel, length: 2, m: nil, x: nil },
                  { opcode: 0x10, mnemonic: 'BPL', mode: :rel, length: 2, m: nil, x: nil },
                  { opcode: 0x80, mnemonic: 'BRA', mode: :rel, length: 2, m: nil, x: nil },
                  { opcode: 0x50, mnemonic: 'BVC', mode: :rel, length: 2, m: nil, x: nil },
                  { opcode: 0x70, mnemonic: 'BVS', mode: :rel, length: 2, m: nil, x: nil },
                  { opcode: 0x82, mnemonic: 'BRL', mode: :rell, length: 3, m: nil, x: nil },
                  { opcode: 0x4c, mnemonic: 'JMP', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x5c, mnemonic: 'JMP', mode: :abl, length: 4, m: nil, x: nil },
                  { opcode: 0x6c, mnemonic: 'JMP', mode: :ind, length: 3, m: nil, x: nil },
                  { opcode: 0x7c, mnemonic: 'JMP', mode: :iax, length: 3, m: nil, x: nil },
                  { opcode: 0xdc, mnemonic: 'JMP', mode: :ial, length: 3, m: nil, x: nil },
                  { opcode: 0x22, mnemonic: 'JSL', mode: :abl, length: 4, m: nil, x: nil },
                  { opcode: 0x20, mnemonic: 'JSR', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0xfc, mnemonic: 'JSR', mode: :iax, length: 3, m: nil, x: nil },
                  { opcode: 0x6b, mnemonic: 'RTL', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x60, mnemonic: 'RTS', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x00, mnemonic: 'BRK', mode: :imm, length: 2, m: nil, x: nil },
                  { opcode: 0x02, mnemonic: 'COP', mode: :imm, length: 2, m: nil, x: nil },
                  { opcode: 0x40, mnemonic: 'RTI', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x18, mnemonic: 'CLC', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xd8, mnemonic: 'CLD', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x58, mnemonic: 'CLI', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xb8, mnemonic: 'CLV', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x38, mnemonic: 'SEC', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xf8, mnemonic: 'SED', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x78, mnemonic: 'SEI', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xc2, mnemonic: 'REP', mode: :imm8, length: 2, m: nil, x: nil },
                  { opcode: 0xe2, mnemonic: 'SEP', mode: :imm8, length: 2, m: nil, x: nil },
                  { opcode: 0xa1, mnemonic: 'LDA', mode: :idx, length: 2, m: nil, x: nil },
                  { opcode: 0xa3, mnemonic: 'LDA', mode: :sr, length: 2, m: nil, x: nil },
                  { opcode: 0xa5, mnemonic: 'LDA', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0xa7, mnemonic: 'LDA', mode: :idl, length: 2, m: nil, x: nil },
                  { opcode: 0xa9, mnemonic: 'LDA', mode: :imm8, length: 2, m: 1, x: nil },
                  { opcode: 0xa9, mnemonic: 'LDA', mode: :imm16, length: 3, m: 0, x: nil },
                  { opcode: 0xad, mnemonic: 'LDA', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0xaf, mnemonic: 'LDA', mode: :abl, length: 4, m: nil, x: nil },
                  { opcode: 0xb1, mnemonic: 'LDA', mode: :idy, length: 2, m: nil, x: nil },
                  { opcode: 0xb2, mnemonic: 'LDA', mode: :idp, length: 2, m: nil, x: nil },
                  { opcode: 0xb3, mnemonic: 'LDA', mode: :isy, length: 2, m: nil, x: nil },
                  { opcode: 0xb5, mnemonic: 'LDA', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0xb7, mnemonic: 'LDA', mode: :idly, length: 2, m: nil, x: nil },
                  { opcode: 0xb9, mnemonic: 'LDA', mode: :aby, length: 3, m: nil, x: nil },
                  { opcode: 0xbd, mnemonic: 'LDA', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0xbf, mnemonic: 'LDA', mode: :alx, length: 4, m: nil, x: nil },
                  { opcode: 0xa2, mnemonic: 'LDX', mode: :imm8, length: 2, m: nil, x: 1 },
                  { opcode: 0xa2, mnemonic: 'LDX', mode: :imm16, length: 3, m: nil, x: 0 },
                  { opcode: 0xa6, mnemonic: 'LDX', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0xae, mnemonic: 'LDX', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0xb6, mnemonic: 'LDX', mode: :dpy, length: 2, m: nil, x: nil },
                  { opcode: 0xbe, mnemonic: 'LDX', mode: :aby, length: 3, m: nil, x: nil },
                  { opcode: 0xa0, mnemonic: 'LDY', mode: :imm8, length: 2, m: nil, x: 1 },
                  { opcode: 0xa0, mnemonic: 'LDY', mode: :imm16, length: 3, m: nil, x: 0 },
                  { opcode: 0xa4, mnemonic: 'LDY', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0xac, mnemonic: 'LDY', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0xb4, mnemonic: 'LDY', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0xbc, mnemonic: 'LDY', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0x81, mnemonic: 'STA', mode: :idx, length: 2, m: nil, x: nil },
                  { opcode: 0x83, mnemonic: 'STA', mode: :sr, length: 2, m: nil, x: nil },
                  { opcode: 0x85, mnemonic: 'STA', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x87, mnemonic: 'STA', mode: :idl, length: 2, m: nil, x: nil },
                  { opcode: 0x8d, mnemonic: 'STA', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x8f, mnemonic: 'STA', mode: :abl, length: 4, m: nil, x: nil },
                  { opcode: 0x91, mnemonic: 'STA', mode: :idy, length: 2, m: nil, x: nil },
                  { opcode: 0x92, mnemonic: 'STA', mode: :idp, length: 2, m: nil, x: nil },
                  { opcode: 0x93, mnemonic: 'STA', mode: :isy, length: 2, m: nil, x: nil },
                  { opcode: 0x95, mnemonic: 'STA', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0x97, mnemonic: 'STA', mode: :idly, length: 2, m: nil, x: nil },
                  { opcode: 0x99, mnemonic: 'STA', mode: :aby, length: 3, m: nil, x: nil },
                  { opcode: 0x9d, mnemonic: 'STA', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0x9f, mnemonic: 'STA', mode: :alx, length: 4, m: nil, x: nil },
                  { opcode: 0x86, mnemonic: 'STX', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x8e, mnemonic: 'STX', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x96, mnemonic: 'STX', mode: :dpy, length: 2, m: nil, x: nil },
                  { opcode: 0x84, mnemonic: 'STY', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x8c, mnemonic: 'STY', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x94, mnemonic: 'STY', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0x64, mnemonic: 'STZ', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x74, mnemonic: 'STZ', mode: :dpx, length: 2, m: nil, x: nil },
                  { opcode: 0x9c, mnemonic: 'STZ', mode: :abs, length: 3, m: nil, x: nil },
                  { opcode: 0x9e, mnemonic: 'STZ', mode: :abx, length: 3, m: nil, x: nil },
                  { opcode: 0x54, mnemonic: 'MVN', mode: :bm, length: 3, m: nil, x: nil },
                  { opcode: 0x44, mnemonic: 'MVP', mode: :bm, length: 3, m: nil, x: nil },
                  { opcode: 0xea, mnemonic: 'NOP', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x42, mnemonic: 'WDM', mode: :imm, length: 2, m: nil, x: nil },
                  { opcode: 0xf4, mnemonic: 'PEA', mode: :iml, length: 3, m: nil, x: nil },
                  { opcode: 0xd4, mnemonic: 'PEI', mode: :dp, length: 2, m: nil, x: nil },
                  { opcode: 0x62, mnemonic: 'PER', mode: :rell, length: 3, m: nil, x: nil },
                  { opcode: 0x48, mnemonic: 'PHA', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xda, mnemonic: 'PHX', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x5a, mnemonic: 'PHY', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x68, mnemonic: 'PLA', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xfa, mnemonic: 'PLX', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x7a, mnemonic: 'PLY', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x8b, mnemonic: 'PHB', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x0b, mnemonic: 'PHD', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x4b, mnemonic: 'PHK', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x08, mnemonic: 'PHP', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xab, mnemonic: 'PLB', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x2b, mnemonic: 'PLD', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x28, mnemonic: 'PLP', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xdb, mnemonic: 'STP', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xcb, mnemonic: 'WAI', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xaa, mnemonic: 'TAX', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xa8, mnemonic: 'TAY', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xba, mnemonic: 'TSX', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x8a, mnemonic: 'TXA', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x9a, mnemonic: 'TXS', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x9b, mnemonic: 'TXY', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x98, mnemonic: 'TYA', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xbb, mnemonic: 'TYX', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x5b, mnemonic: 'TCD', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x1b, mnemonic: 'TCS', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x7b, mnemonic: 'TDC', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0x3b, mnemonic: 'TSC', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xeb, mnemonic: 'XBA', mode: :imp, length: 1, m: nil, x: nil },
                  { opcode: 0xfb, mnemonic: 'XCE', mode: :imp, length: 1, m: nil, x: nil }].freeze
end
