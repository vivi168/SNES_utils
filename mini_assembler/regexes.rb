module Regexes
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
end
