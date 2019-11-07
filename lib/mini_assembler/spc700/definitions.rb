module SnesUtils
  module Spc700
    class Definitions
      HEX_DIGIT = '[0-9a-f]'
      HEX8  = "\\$?(#{HEX_DIGIT}{1,2})"
      HEX16 = "\\$?(#{HEX_DIGIT}{3,4})"

      MODES_REGEXES = {
        imp:      /^$/
        abs:      /^#{HEX16}$/i        # !a
        abspxa:   /^#{HEX16}\+x,a$/i   # !a+X, A
        abspya:   /^#{HEX16}\+y,a$/i   # !a+Y, A
        absa:     /^#{HEX16},a$/i      # !a, A
        absx:     /^#{HEX16},x$/i      # !a, X
        absy:     /^#{HEX16},y$/i      # !a, Y
        idxpacc:  /^\(x\)\+,a$/i   # (X)+, A
        idxidy:   /^\(x\),\(y\)$/i # (X), (Y)
        idxacc:   /^\(x\),a$/i     # (X), A
        t0:       /^0$/i   # 0
        t1:       /^1$/i   # 1
        t2:       /^2$/i   # 2
        t3:       /^3$/i   # 3
        t4:       /^4$/i   # 4
        t5:       /^5$/i   # 5
        t6:       /^6$/i   # 6
        t7:       /^7$/i   # 7
        t8:       /^8$/i   # 8
        t9:       /^9$/i   # 9
        t10:      /^10$/i # 10
        t11:      /^11$/i # 11
        t12:      /^12$/i # 12
        t13:      /^13$/i # 13
        t14:      /^14$/i # 14
        t15:      /^15$/i # 15
        absix:    /^\[#{HEX16}\+x\]$/i    # [!a+X]
        dpixacc:  /^\[#{HEX8}\+x\],a$/i # [d+X], A
        dpiyacc:  /^\[#{HEX8}\]+y$/i    # [d]+Y, A
        acc:      /^a$/i                    # A
        accabs:   /^a,#{HEX16}$/i        # A, !a
        accabsx:  /^a,#{HEX16}+x$/i     # A, !a+X
        accabsy:  /^a,#{HEX16}+y$/i     # A, !a+Y
        accimp:   /^a,##{HEX8}$/i        # A, #i
        accidx:   /^a,\(x\)$/i           # A, (X)
        accidxp:  /^a,\(x\)\+$/i        # A, (X)+
        accdpix:  /^a,\[#{HEX8}\+x\]$/i # A, [d+X]
        accdpiy:  /^a,\[#{HEX8}\]\+y$/i # A, [d]+Y
        accdp:    /^a,#{HEX8}$/i          # A, d
        accdpx:   /^a,#{HEX8}\+x$/i      # A, d+X
        accx:     /^a,x$/i                 # A, X
        accy:     /^a,y$/i                 # A, Y
        cnmb:     /^c,\/#{HEX16}\.([0-7])$/i # C, /m.b
        cmb:      /^c,#{HEX16}\.([0-7])$/i    # C, m.b
        dp:       /^#{HEX8}$/i                 # d
        dppx:     /^#{HEX8}\+x$/i            # d+X
        dppxa:    /^#{HEX8}\+x,a$/i         # d+X, A
        dpxrel:   /^#{HEX8}\+x,#{HEX16}$/i # d+X, r
        dppxy:    /^#{HEX8}\+x,y$/i         # d+X, Y
        dppyx:    /^#{HEX8}\+y,x$/i         # d+Y, X
        dpimm:    /^#{HEX8},##{HEX8}$/i     # d, #i
        dpa:      /^#{HEX8},a$/i              # d, A
        dprel:    /^#{HEX8},#{HEX16}$/i     # d, r
        dpx:      /^#{HEX8},x$/i              # d, X
        dpy:      /^#{HEX8},y$/i              # d, Y
        dpya:     /^#{HEX8},ya$/i            # d, YA
        dp0:      /^#{HEX8}\.0$/i             # d.0
        dp0rel:   /^#{HEX8}\.0,#{HEX16}$/i # d.0, r
        dp1:      /^#{HEX8}\.1$/i             # d.1
        dp1rel:   /^#{HEX8}\.1,#{HEX16}$/i # d.1, r
        dp2:      /^#{HEX8}\.2$/i             # d.2
        dp2rel:   /^#{HEX8}\.2,#{HEX16}$/i # d.2, r
        dp3:      /^#{HEX8}\.3$/i             # d.3
        dp3rel:   /^#{HEX8}\.3,#{HEX16}$/i # d.3, r
        dp4:      /^#{HEX8}\.4$/i             # d.4
        dp4rel:   /^#{HEX8}\.4,#{HEX16}$/i # d.4, r
        dp5:      /^#{HEX8}\.5$/i             # d.5
        dp5rel:   /^#{HEX8}\.5,#{HEX16}$/i # d.5, r
        dp6:      /^#{HEX8}\.6$/i             # d.6
        dp6rel:   /^#{HEX8}\.6,#{HEX16}$/i # d.6, r
        dp7:      /^#{HEX8}\.7$/i             # d.7
        dp7rel:   /^#{HEX8}\.7,#{HEX16}$/i # d.7, r
        ddds:     /^#{HEX8}<d>,#{HEX8}<s>$/i # d<d>, d<s>
        mb:       /^#{HEX16}\.([0-7])$/i    # m.b
        mbc:      /^#{HEX16}\.([0-7]),c$/i # m.b, C
        psw:      /^psw$/i        # PSW
        rel:      /^#{HEX16}$/i   # r
        spx:      /^sp,x$/i       # SP, X
        upage:    /^#{HEX8}$/i  # u
        x:        /^x$/i              # X
        xabs:     /^x,#{HEX16}$/i     # X, !a
        ximm:     /^x,##{HEX8}$/i     # X, #i
        xa:       /^x,a$/i            # X, A
        xdp:      /^x,#{HEX8}$/i      # X, d
        xdpy:     /^x,#{HEX8}\+y$/i   # X, d+Y
        xsp:      /^x,sp$/i           # X, SP
        y:        /^y$/i              # Y
        yabs:     /^y,#{HEX16}$/i     # Y, !a
        yimm:     /^y,##{HEX8}$/i     # Y, #i
        yacc:     /^y,a$/i            # Y, A
        ydp:      /^y,#{HEX8}$/i      # Y, d
        ydpx:     /^y,#{HEX8}\+x$/i # Y, d+X
        yrel:     /^y,#{HEX16}$/i   # Y, r
        ya:       /^ya$/i           # YA
        yadp:     /^ya,#{HEX8}$/i   # YA, d
        yax:      /^ya,x$/i         # YA, X
      }

      MODES_FORMATS = {
        imp:      "%s",
        abs:      "%s !%04X",
        abspxa:   "%s !%04X+X, A",
        abspya:   "%s !%04X+Y, A",
        absa:     "%s !%04X, A",
        absx:     "%s !%04X, X",
        absy:     "%s !%04X, Y",
        idxpacc:  "%s (X)+, A",
        idxidy:   "%s (X), (Y)",
        idxacc:   "%s (X), A",
        t0:       "%s 0",
        t1:       "%s 1",
        t2:       "%s 2",
        t3:       "%s 3",
        t4:       "%s 4",
        t5:       "%s 5",
        t6:       "%s 6",
        t7:       "%s 7",
        t8:       "%s 8",
        t9:       "%s 9",
        t10:      "%s 10",
        t11:      "%s 11",
        t12:      "%s 12",
        t13:      "%s 13",
        t14:      "%s 14",
        t15:      "%s 15",
        absix:    "%s [!%04X+X]",
        dpixacc:  "%s [%02X+X], A",
        dpiyacc:  "%s [%02X]+Y, A",
        acc:      "%s A",
        accabs:   "%s A, !%04X",
        accabsx:  "%s A, !%04X+X",
        accabsy:  "%s A, !%04X+Y",
        accimp:   "%s A, #%02X",
        accidx:   "%s A, (X)",
        accidxp:  "%s A, (X)+",
        accdpix:  "%s A, [%02X+X]",
        accdpiy:  "%s A, [%02X]+Y",
        accdp:    "%s A, %02X",
        accdpx:   "%s A, %02X+X",
        accx:     "%s A, X",
        accy:     "%s A, Y",
        cnmb:     "%s C, /%04X.%X",
        cmb:      "%s C, %04X.%X",
        dp:       "%s %02X",
        dppx:     "%s %02X+X",
        dppxa:    "%s %02X+X, A",
        dpxrel:   "%s %02X+X, %04X {%s}",
        dppxy:    "%s %02X+X, Y",
        dppyx:    "%s %02X+Y, X",
        dpimm:    "%s %02X, #%02X",
        dpa:      "%s %02X, A",
        dprel:    "%s %02X, %04X {%s}",
        dpx:      "%s %02X, X",
        dpy:      "%s %02X, Y",
        dpya:     "%s %02X, YA",
        dp0:      "%s %02X.0",
        dp0rel:   "%s %02X.0, %04X {%s}",
        dp1:      "%s %02X.1",
        dp1rel:   "%s %02X.1, %04X {%s}",
        dp2:      "%s %02X.2",
        dp2rel:   "%s %02X.2, %04X {%s}",
        dp3:      "%s %02X.3",
        dp3rel:   "%s %02X.3, %04X {%s}",
        dp4:      "%s %02X.4",
        dp4rel:   "%s %02X.4, %04X {%s}",
        dp5:      "%s %02X.5",
        dp5rel:   "%s %02X.5, %04X {%s}",
        dp6:      "%s %02X.6",
        dp6rel:   "%s %02X.6, %04X {%s}",
        dp7:      "%s %02X.7",
        dp7rel:   "%s %02X.7, %04X {%s}",
        ddds:     "%s %02X<d>, %02X<s>",
        mb:       "%s %04X.%X",
        mbc:      "%s %04X.%X, C",
        psw:      "%s PSW",
        rel:      "%s %04X {%s}",
        spx:      "%s SP, X",
        upage:    "%s %02X",
        x:        "%s X",
        xabs:     "%s X, !%04X",
        ximm:     "%s X, #%02X",
        xa:       "%s X, A",
        xdp:      "%s X, %02X",
        xdpy:     "%s X, %02X+Y",
        xsp:      "%s X, SP",
        y:        "%s Y",
        yabs:     "%s Y, !%04X",
        yimm:     "%s Y, #%02X",
        ya:       "%s Y, A",
        ydp:      "%s Y, %02X",
        ydpx:     "%s Y, %02X+X",
        yrel:     "%s Y, %04X {%s}",
        ya:       "%s YA",
        yadp:     "%s YA, %02X",
        yax:      "%s YA, X"
      }

      OPCODES_DATA = [{ opcode: 0x99, mnemonic: "ADC", mode: :idxidy, length: 1},
                      { opcode: 0x88, mnemonic: "ADC", mode: :accimp, length: 2},
                      { opcode: 0x86, mnemonic: "ADC", mode: :accidx, length: 1},
                      { opcode: 0x97, mnemonic: "ADC", mode: :accdpiy, length: 2},
                      { opcode: 0x87, mnemonic: "ADC", mode: :accdpix, length: 2},
                      { opcode: 0x84, mnemonic: "ADC", mode: :accdp, length: 2},
                      { opcode: 0x94, mnemonic: "ADC", mode: :accdpx, length: 2},
                      { opcode: 0x85, mnemonic: "ADC", mode: :accabs, length: 3},
                      { opcode: 0x95, mnemonic: "ADC", mode: :accabsx, length: 3},
                      { opcode: 0x96, mnemonic: "ADC", mode: :accabsy, length: 3},
                      { opcode: 0x89, mnemonic: "ADC", mode: :ddds, length: 3},
                      { opcode: 0x98, mnemonic: "ADC", mode: :dpimm, length: 3},
                      { opcode: 0x7A, mnemonic: "ADDW", mode: :yadp, length: 2},
                      { opcode: 0x39, mnemonic: "AND", mode: :idxidy, length: 1},
                      { opcode: 0x28, mnemonic: "AND", mode: :accimp, length: 2},
                      { opcode: 0x26, mnemonic: "AND", mode: :accidx, length: 1},
                      { opcode: 0x37, mnemonic: "AND", mode: :accdpiy, length: 2},
                      { opcode: 0x27, mnemonic: "AND", mode: :accdpix, length: 2},
                      { opcode: 0x24, mnemonic: "AND", mode: :accdp, length: 2},
                      { opcode: 0x34, mnemonic: "AND", mode: :accdpx, length: 2},
                      { opcode: 0x25, mnemonic: "AND", mode: :accabs, length: 3},
                      { opcode: 0x35, mnemonic: "AND", mode: :accabsx, length: 3},
                      { opcode: 0x36, mnemonic: "AND", mode: :accabsy, length: 3},
                      { opcode: 0x29, mnemonic: "AND", mode: :ddds, length: 3},
                      { opcode: 0x38, mnemonic: "AND", mode: :dpimm, length: 3},
                      { opcode: 0x6A, mnemonic: "AND1", mode: :cnmb, length: 3},
                      { opcode: 0x4A, mnemonic: "AND1", mode: :cmb, length: 3},
                      { opcode: 0x1C, mnemonic: "ASL", mode: :acc, length: 1},
                      { opcode: 0x0B, mnemonic: "ASL", mode: :dp, length: 2},
                      { opcode: 0x1B, mnemonic: "ASL", mode: :dppx, length: 2},
                      { opcode: 0x0C, mnemonic: "ASL", mode: :abs, length: 3},
                      { opcode: 0x13, mnemonic: "BBC", mode: :dp0rel, length: 3},
                      { opcode: 0x33, mnemonic: "BBC", mode: :dp1rel, length: 3},
                      { opcode: 0x53, mnemonic: "BBC", mode: :dp2rel, length: 3},
                      { opcode: 0x73, mnemonic: "BBC", mode: :dp3rel, length: 3},
                      { opcode: 0x93, mnemonic: "BBC", mode: :dp4rel, length: 3},
                      { opcode: 0xB3, mnemonic: "BBC", mode: :dp5rel, length: 3},
                      { opcode: 0xD3, mnemonic: "BBC", mode: :dp6rel, length: 3},
                      { opcode: 0xF3, mnemonic: "BBC", mode: :dp7rel, length: 3},
                      { opcode: 0x03, mnemonic: "BBS", mode: :dp0rel, length: 3},
                      { opcode: 0x23, mnemonic: "BBS", mode: :dp1rel, length: 3},
                      { opcode: 0x43, mnemonic: "BBS", mode: :dp2rel, length: 3},
                      { opcode: 0x63, mnemonic: "BBS", mode: :dp3rel, length: 3},
                      { opcode: 0x83, mnemonic: "BBS", mode: :dp4rel, length: 3},
                      { opcode: 0xA3, mnemonic: "BBS", mode: :dp5rel, length: 3},
                      { opcode: 0xC3, mnemonic: "BBS", mode: :dp6rel, length: 3},
                      { opcode: 0xE3, mnemonic: "BBS", mode: :dp7rel, length: 3},
                      { opcode: 0x90, mnemonic: "BCC", mode: :rel, length: 2},
                      { opcode: 0xB0, mnemonic: "BCS", mode: :rel, length: 2},
                      { opcode: 0xF0, mnemonic: "BEQ", mode: :rel, length: 2},
                      { opcode: 0x30, mnemonic: "BMI", mode: :rel, length: 2},
                      { opcode: 0xD0, mnemonic: "BNE", mode: :rel, length: 2},
                      { opcode: 0x10, mnemonic: "BPL", mode: :rel, length: 2},
                      { opcode: 0x50, mnemonic: "BVC", mode: :rel, length: 2},
                      { opcode: 0x70, mnemonic: "BVS", mode: :rel, length: 2},
                      { opcode: 0x2F, mnemonic: "BRA", mode: :rel, length: 2},
                      { opcode: 0x0F, mnemonic: "BRK", mode: :imp, length: 1},
                      { opcode: 0x3F, mnemonic: "CALL", mode: :abs, length: 3},
                      { opcode: 0xDE, mnemonic: "CBNE", mode: :dpxrel, length: 3},
                      { opcode: 0x2E, mnemonic: "CBNE", mode: :dprel, length: 3},
                      { opcode: 0x12, mnemonic: "CLR1", mode: :dp0, length: 2},
                      { opcode: 0x32, mnemonic: "CLR1", mode: :dp1, length: 2},
                      { opcode: 0x52, mnemonic: "CLR1", mode: :dp2, length: 2},
                      { opcode: 0x72, mnemonic: "CLR1", mode: :dp3, length: 2},
                      { opcode: 0x92, mnemonic: "CLR1", mode: :dp4, length: 2},
                      { opcode: 0xB2, mnemonic: "CLR1", mode: :dp5, length: 2},
                      { opcode: 0xD2, mnemonic: "CLR1", mode: :dp6, length: 2},
                      { opcode: 0xF2, mnemonic: "CLR1", mode: :dp7, length: 2},
                      { opcode: 0x60, mnemonic: "CLRC", mode: :imp, length: 1},
                      { opcode: 0x20, mnemonic: "CLRP", mode: :imp, length: 1},
                      { opcode: 0xE0, mnemonic: "CLRV", mode: :imp, length: 1},
                      { opcode: 0x79, mnemonic: "CMP", mode: :idxidy, length: 1},
                      { opcode: 0x68, mnemonic: "CMP", mode: :accimp, length: 2},
                      { opcode: 0x66, mnemonic: "CMP", mode: :accidx, length: 1},
                      { opcode: 0x77, mnemonic: "CMP", mode: :accdpiy, length: 2},
                      { opcode: 0x67, mnemonic: "CMP", mode: :accdpix, length: 2},
                      { opcode: 0x64, mnemonic: "CMP", mode: :accdp, length: 2},
                      { opcode: 0x74, mnemonic: "CMP", mode: :accdpx, length: 2},
                      { opcode: 0x65, mnemonic: "CMP", mode: :accabs, length: 3},
                      { opcode: 0x75, mnemonic: "CMP", mode: :accabsx, length: 3},
                      { opcode: 0x76, mnemonic: "CMP", mode: :accabsy, length: 3},
                      { opcode: 0xC8, mnemonic: "CMP", mode: :ximm, length: 2},
                      { opcode: 0x3E, mnemonic: "CMP", mode: :xdp, length: 2},
                      { opcode: 0x1E, mnemonic: "CMP", mode: :xabs, length: 3},
                      { opcode: 0xAD, mnemonic: "CMP", mode: :yimm, length: 2},
                      { opcode: 0x7E, mnemonic: "CMP", mode: :ydp, length: 2},
                      { opcode: 0x5E, mnemonic: "CMP", mode: :yabs, length: 3},
                      { opcode: 0x69, mnemonic: "CMP", mode: :ddds, length: 3},
                      { opcode: 0x78, mnemonic: "CMP", mode: :dpimm, length: 3},
                      { opcode: 0x5A, mnemonic: "CMPW", mode: :yadp, length: 2},
                      { opcode: 0xDF, mnemonic: "DAA", mode: :acc, length: 1},
                      { opcode: 0xBE, mnemonic: "DAS", mode: :acc, length: 1},
                      { opcode: 0xFE, mnemonic: "DBNZ", mode: :yrel, length: 2},
                      { opcode: 0x6E, mnemonic: "DBNZ", mode: :dprel, length: 3},
                      { opcode: 0x9C, mnemonic: "DEC", mode: :acc, length: 1},
                      { opcode: 0x1D, mnemonic: "DEC", mode: :x, length: 1},
                      { opcode: 0xDC, mnemonic: "DEC", mode: :y, length: 1},
                      { opcode: 0x8B, mnemonic: "DEC", mode: :dp, length: 2},
                      { opcode: 0x9B, mnemonic: "DEC", mode: :dppx, length: 2},
                      { opcode: 0x8C, mnemonic: "DEC", mode: :abs, length: 3},
                      { opcode: 0x1A, mnemonic: "DECW", mode: :dp, length: 2},
                      { opcode: 0xC0, mnemonic: "DI", mode: :imp, length: 1},
                      { opcode: 0x9E, mnemonic: "DIV", mode: :yax, length: 1},
                      { opcode: 0xA0, mnemonic: "EI", mode: :imp, length: 1},
                      { opcode: 0x59, mnemonic: "EOR", mode: :idxidy, length: 1},
                      { opcode: 0x48, mnemonic: "EOR", mode: :accimp, length: 2},
                      { opcode: 0x46, mnemonic: "EOR", mode: :accidx, length: 1},
                      { opcode: 0x57, mnemonic: "EOR", mode: :accdpiy, length: 2},
                      { opcode: 0x47, mnemonic: "EOR", mode: :accdpix, length: 2},
                      { opcode: 0x44, mnemonic: "EOR", mode: :accdp, length: 2},
                      { opcode: 0x54, mnemonic: "EOR", mode: :accdpx, length: 2},
                      { opcode: 0x45, mnemonic: "EOR", mode: :accabs, length: 3},
                      { opcode: 0x55, mnemonic: "EOR", mode: :accabsx, length: 3},
                      { opcode: 0x56, mnemonic: "EOR", mode: :accabsy, length: 3},
                      { opcode: 0x49, mnemonic: "EOR", mode: :ddds, length: 3},
                      { opcode: 0x58, mnemonic: "EOR", mode: :dpimm, length: 3},
                      { opcode: 0x8A, mnemonic: "EOR1", mode: :cmb, length: 3},
                      { opcode: 0xBC, mnemonic: "INC", mode: :acc, length: 1},
                      { opcode: 0x3D, mnemonic: "INC", mode: :x, length: 1},
                      { opcode: 0xFC, mnemonic: "INC", mode: :y, length: 1},
                      { opcode: 0xAB, mnemonic: "INC", mode: :dp, length: 2},
                      { opcode: 0xBB, mnemonic: "INC", mode: :dppx, length: 2},
                      { opcode: 0xAC, mnemonic: "INC", mode: :abs, length: 3},
                      { opcode: 0x3A, mnemonic: "INCW", mode: :dp, length: 2},
                      { opcode: 0x1F, mnemonic: "JMP", mode: :absix, length: 3},
                      { opcode: 0x5F, mnemonic: "JMP", mode: :abs, length: 3},
                      { opcode: 0x5C, mnemonic: "LSR", mode: :acc, length: 1},
                      { opcode: 0x4B, mnemonic: "LSR", mode: :dp, length: 2},
                      { opcode: 0x5B, mnemonic: "LSR", mode: :dppx, length: 2},
                      { opcode: 0x4C, mnemonic: "LSR", mode: :abs, length: 3},
                      { opcode: 0xAF, mnemonic: "MOV", mode: :idxpacc, length: 1},
                      { opcode: 0xC6, mnemonic: "MOV", mode: :idxacc, length: 1},
                      { opcode: 0xD7, mnemonic: "MOV", mode: :dpiyacc, length: 2},
                      { opcode: 0xC7, mnemonic: "MOV", mode: :dpixacc, length: 2},
                      { opcode: 0xE8, mnemonic: "MOV", mode: :accimp, length: 2},
                      { opcode: 0xE6, mnemonic: "MOV", mode: :accidx, length: 1},
                      { opcode: 0xBF, mnemonic: "MOV", mode: :accidxp, length: 1},
                      { opcode: 0xF7, mnemonic: "MOV", mode: :accdpiy, length: 2},
                      { opcode: 0xE7, mnemonic: "MOV", mode: :accdpix, length: 2},
                      { opcode: 0x7D, mnemonic: "MOV", mode: :accx, length: 1},
                      { opcode: 0xDD, mnemonic: "MOV", mode: :accy, length: 1},
                      { opcode: 0xE4, mnemonic: "MOV", mode: :accdp, length: 2},
                      { opcode: 0xF4, mnemonic: "MOV", mode: :accdpx, length: 2},
                      { opcode: 0xE5, mnemonic: "MOV", mode: :accabs, length: 3},
                      { opcode: 0xF5, mnemonic: "MOV", mode: :accabsx, length: 3},
                      { opcode: 0xF6, mnemonic: "MOV", mode: :accabsy, length: 3},
                      { opcode: 0xBD, mnemonic: "MOV", mode: :spx, length: 1},
                      { opcode: 0xCD, mnemonic: "MOV", mode: :ximm, length: 2},
                      { opcode: 0x5D, mnemonic: "MOV", mode: :xa, length: 1},
                      { opcode: 0x9D, mnemonic: "MOV", mode: :xsp, length: 1},
                      { opcode: 0xF8, mnemonic: "MOV", mode: :xdp, length: 2},
                      { opcode: 0xF9, mnemonic: "MOV", mode: :xdpy, length: 2},
                      { opcode: 0xE9, mnemonic: "MOV", mode: :xabs, length: 3},
                      { opcode: 0x8D, mnemonic: "MOV", mode: :yimm, length: 2},
                      { opcode: 0xFD, mnemonic: "MOV", mode: :yacc, length: 1},
                      { opcode: 0xEB, mnemonic: "MOV", mode: :ydp, length: 2},
                      { opcode: 0xFB, mnemonic: "MOV", mode: :ydpx, length: 2},
                      { opcode: 0xEC, mnemonic: "MOV", mode: :yabs, length: 3},
                      { opcode: 0xFA, mnemonic: "MOV", mode: :ddds, length: 3},
                      { opcode: 0xD4, mnemonic: "MOV", mode: :dppxa, length: 2},
                      { opcode: 0xDB, mnemonic: "MOV", mode: :dppxy, length: 2},
                      { opcode: 0xD9, mnemonic: "MOV", mode: :dppyx, length: 2},
                      { opcode: 0x8F, mnemonic: "MOV", mode: :dpimm, length: 3},
                      { opcode: 0xC4, mnemonic: "MOV", mode: :dpa, length: 2},
                      { opcode: 0xD8, mnemonic: "MOV", mode: :dpx, length: 2},
                      { opcode: 0xCB, mnemonic: "MOV", mode: :dpy, length: 2},
                      { opcode: 0xD5, mnemonic: "MOV", mode: :abspxa, length: 3},
                      { opcode: 0xD6, mnemonic: "MOV", mode: :abspya, length: 3},
                      { opcode: 0xC5, mnemonic: "MOV", mode: :absa, length: 3},
                      { opcode: 0xC9, mnemonic: "MOV", mode: :absx, length: 3},
                      { opcode: 0xCC, mnemonic: "MOV", mode: :absy, length: 3},
                      { opcode: 0xAA, mnemonic: "MOV1", mode: :cmb, length: 3},
                      { opcode: 0xCA, mnemonic: "MOV1", mode: :mbc, length: 3},
                      { opcode: 0xBA, mnemonic: "MOVW", mode: :yadp, length: 2},
                      { opcode: 0xDA, mnemonic: "MOVW", mode: :dpya, length: 2},
                      { opcode: 0xCF, mnemonic: "MUL", mode: :ya, length: 1},
                      { opcode: 0x00, mnemonic: "NOP", mode: :imp, length: 1},
                      { opcode: 0xEA, mnemonic: "NOT1", mode: :mb, length: 3},
                      { opcode: 0xED, mnemonic: "NOTC", mode: :imp, length: 1},
                      { opcode: 0x19, mnemonic: "OR", mode: :idxidy, length: 1},
                      { opcode: 0x08, mnemonic: "OR", mode: :accimp, length: 2},
                      { opcode: 0x06, mnemonic: "OR", mode: :accidx, length: 1},
                      { opcode: 0x17, mnemonic: "OR", mode: :accdpiy, length: 2},
                      { opcode: 0x07, mnemonic: "OR", mode: :accdpix, length: 2},
                      { opcode: 0x04, mnemonic: "OR", mode: :accdp, length: 2},
                      { opcode: 0x14, mnemonic: "OR", mode: :accdpx, length: 2},
                      { opcode: 0x05, mnemonic: "OR", mode: :accabs, length: 3},
                      { opcode: 0x15, mnemonic: "OR", mode: :accabsx, length: 3},
                      { opcode: 0x16, mnemonic: "OR", mode: :accabsy, length: 3},
                      { opcode: 0x09, mnemonic: "OR", mode: :ddds, length: 3},
                      { opcode: 0x18, mnemonic: "OR", mode: :dpimm, length: 3},
                      { opcode: 0x2A, mnemonic: "OR1", mode: :cnmb, length: 3},
                      { opcode: 0x0A, mnemonic: "OR1", mode: :cmb, length: 3},
                      { opcode: 0x4F, mnemonic: "PCALL", mode: :upage, length: 2},
                      { opcode: 0xAE, mnemonic: "POP", mode: :acc, length: 1},
                      { opcode: 0x8E, mnemonic: "POP", mode: :psw, length: 1},
                      { opcode: 0xCE, mnemonic: "POP", mode: :x, length: 1},
                      { opcode: 0xEE, mnemonic: "POP", mode: :y, length: 1},
                      { opcode: 0x2D, mnemonic: "PUSH", mode: :acc, length: 1},
                      { opcode: 0x0D, mnemonic: "PUSH", mode: :psw, length: 1},
                      { opcode: 0x4D, mnemonic: "PUSH", mode: :x, length: 1},
                      { opcode: 0x6D, mnemonic: "PUSH", mode: :y, length: 1},
                      { opcode: 0x6F, mnemonic: "RET", mode: :imp, length: 1},
                      { opcode: 0x7F, mnemonic: "RET1", mode: :imp, length: 1},
                      { opcode: 0x3C, mnemonic: "ROL", mode: :acc, length: 1},
                      { opcode: 0x2B, mnemonic: "ROL", mode: :dp, length: 2},
                      { opcode: 0x3B, mnemonic: "ROL", mode: :dppx, length: 2},
                      { opcode: 0x2C, mnemonic: "ROL", mode: :abs, length: 3},
                      { opcode: 0x7C, mnemonic: "ROR", mode: :acc, length: 1},
                      { opcode: 0x6B, mnemonic: "ROR", mode: :dp, length: 2},
                      { opcode: 0x7B, mnemonic: "ROR", mode: :dppx, length: 2},
                      { opcode: 0x6C, mnemonic: "ROR", mode: :abs, length: 3},
                      { opcode: 0xB9, mnemonic: "SBC", mode: :idxidy, length: 1},
                      { opcode: 0xA8, mnemonic: "SBC", mode: :accimp, length: 2},
                      { opcode: 0xA6, mnemonic: "SBC", mode: :accidx, length: 1},
                      { opcode: 0xB7, mnemonic: "SBC", mode: :accdpiy, length: 2},
                      { opcode: 0xA7, mnemonic: "SBC", mode: :accdpix, length: 2},
                      { opcode: 0xA4, mnemonic: "SBC", mode: :accdp, length: 2},
                      { opcode: 0xB4, mnemonic: "SBC", mode: :accdpx, length: 2},
                      { opcode: 0xA5, mnemonic: "SBC", mode: :accabs, length: 3},
                      { opcode: 0xB5, mnemonic: "SBC", mode: :accabsx, length: 3},
                      { opcode: 0xB6, mnemonic: "SBC", mode: :accabsy, length: 3},
                      { opcode: 0xA9, mnemonic: "SBC", mode: :ddds, length: 3},
                      { opcode: 0xB8, mnemonic: "SBC", mode: :dpimm, length: 3},
                      { opcode: 0x02, mnemonic: "SET1", mode: :dp0, length: 2},
                      { opcode: 0x22, mnemonic: "SET1", mode: :dp1, length: 2},
                      { opcode: 0x42, mnemonic: "SET1", mode: :dp2, length: 2},
                      { opcode: 0x62, mnemonic: "SET1", mode: :dp3, length: 2},
                      { opcode: 0x82, mnemonic: "SET1", mode: :dp4, length: 2},
                      { opcode: 0xA2, mnemonic: "SET1", mode: :dp5, length: 2},
                      { opcode: 0xC2, mnemonic: "SET1", mode: :dp6, length: 2},
                      { opcode: 0xE2, mnemonic: "SET1", mode: :dp7, length: 2},
                      { opcode: 0x80, mnemonic: "SETC", mode: :imp, length: 1},
                      { opcode: 0x40, mnemonic: "SETP", mode: :imp, length: 1},
                      { opcode: 0xEF, mnemonic: "SLEEP", mode: :imp, length: 1},
                      { opcode: 0xFF, mnemonic: "STOP", mode: :imp, length: 1},
                      { opcode: 0x9A, mnemonic: "SUBW", mode: :yadp, length: 2},
                      { opcode: 0x01, mnemonic: "TCALL", mode: :t0, length: 1},
                      { opcode: 0x11, mnemonic: "TCALL", mode: :t1, length: 1},
                      { opcode: 0x21, mnemonic: "TCALL", mode: :t2, length: 1},
                      { opcode: 0x31, mnemonic: "TCALL", mode: :t3, length: 1},
                      { opcode: 0x41, mnemonic: "TCALL", mode: :t4, length: 1},
                      { opcode: 0x51, mnemonic: "TCALL", mode: :t5, length: 1},
                      { opcode: 0x61, mnemonic: "TCALL", mode: :t6, length: 1},
                      { opcode: 0x71, mnemonic: "TCALL", mode: :t7, length: 1},
                      { opcode: 0x81, mnemonic: "TCALL", mode: :t8, length: 1},
                      { opcode: 0x91, mnemonic: "TCALL", mode: :t9, length: 1},
                      { opcode: 0xA1, mnemonic: "TCALL", mode: :t10, length: 1},
                      { opcode: 0xB1, mnemonic: "TCALL", mode: :t11, length: 1},
                      { opcode: 0xC1, mnemonic: "TCALL", mode: :t12, length: 1},
                      { opcode: 0xD1, mnemonic: "TCALL", mode: :t13, length: 1},
                      { opcode: 0xE1, mnemonic: "TCALL", mode: :t14, length: 1},
                      { opcode: 0xF1, mnemonic: "TCALL", mode: :t15, length: 1},
                      { opcode: 0x4E, mnemonic: "TCLR1", mode: :abs, length: 3},
                      { opcode: 0x0E, mnemonic: "TSET1", mode: :abs, length: 3},
                      { opcode: 0x9F, mnemonic: "XCN", mode: :acc, length: 1}].freeze
    end
  end
end