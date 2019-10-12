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

  BYTE_LOC = /^#{HEX_DIGIT}{1,4}$/i
  BYTE_RANGE = /^(#{HEX_DIGIT}{1,4})\.+(#{HEX_DIGIT}{1,4})$/i
  BYTE_SEQUENCE = /^(#{HEX_DIGIT}{1,4}):\s*([0-9a-f ]+)$/i
  DISASSEMBLE = /^(#{HEX_DIGIT}{1,4})l/i
  SWITCH_BANK = /^([0-9a-f]{2})\/$/i
  FLIP_MX_REG = /^([01])=([xm])$/i
end
