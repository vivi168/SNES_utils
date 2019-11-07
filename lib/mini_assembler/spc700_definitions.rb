module SnesUtils
  class Spc700Definitions
    HEX_DIGIT = '[0-9a-f]'
    HEX8  = "\\$?(#{HEX_DIGIT}{1,2})"
    HEX16 = "\\$?(#{HEX_DIGIT}{3,4})"

    MODES_REGEXES = {
      imp: /^$/
      abs: /^#{HEX16}$/i         # !a
      abspxa: /^#{HEX16}\+x,a$/i # !a+X, A
      abspya: /^#{HEX16}\+y,a$/i # !a+Y, A
      absa: /^#{HEX16},a$/i      # !a, A
      absx: /^#{HEX16},x$/i      # !a, X
      absy: /^#{HEX16},y$/i      # !a, Y
      idxpacc: /^\(x\)\+,a$/i  # (X)+, A
      idxidy: /^\(x\),\(y\)$/i # (X), (Y)
      idxacc: /^\(x\),a$/i     # (X), A
      t0: /^0$/i   # 0
      t1: /^1$/i   # 1
      t2: /^2$/i   # 2
      t3: /^3$/i   # 3
      t4: /^4$/i   # 4
      t5: /^5$/i   # 5
      t6: /^6$/i   # 6
      t7: /^7$/i   # 7
      t8: /^8$/i   # 8
      t9: /^9$/i   # 9
      t10: /^10$/i # 10
      t11: /^11$/i # 11
      t12: /^12$/i # 12
      t13: /^13$/i # 13
      t14: /^14$/i # 14
      t15: /^15$/i # 15
      absix: /^\[#{HEX16}\+x\]$/i    # [!a+X]
      dpixacc: /^\[#{HEX8}\+x\],a$/i # [d+X], A
      dpiyacc: /^\[#{HEX8}\]+y$/i    # [d]+Y, A
      acc: /^a$/i                    # A
      accabs: /^a,#{HEX16}$/i        # A, !a
      accabsx: /^a,#{HEX16}+x$/i     # A, !a+X
      accabsy: /^a,#{HEX16}+y$/i     # A, !a+Y
      accimp: /^a,##{HEX8}$/i        # A, #i
      accidx: /^a,\(x\)$/i           # A, (X)
      accidxp: /^a,\(x\)\+$/i        # A, (X)+
      accdpix: /^a,\[#{HEX8}\+x\]$/i # A, [d+X]
      accdpiy: /^a,\[#{HEX8}\]\+y$/i # A, [d]+Y
      accdp: /^a,#{HEX8}$/i          # A, d
      accdpx: /^a,#{HEX8}\+x$/i      # A, d+X
      accx: /^a,x$/i                 # A, X
      accy: /^a,y$/i                 # A, Y
      cnmb: /^c,\/#{HEX16}\.([0-7])$/i # C, /m.b
      cmb: /^c,#{HEX16}\.([0-7])$/i    # C, m.b
      dp: /^#{HEX8}$/i                 # d
      dppx: /^#{HEX8}\+x$/i            # d+X
      dppxa: /^#{HEX8}\+x,a$/i         # d+X, A
      dpxrel: /^#{HEX8}\+x,#{HEX16}$/i # d+X, r
      dppxy: /^#{HEX8}\+x,y$/i         # d+X, Y
      dppyx: /^#{HEX8}\+y,x$/i         # d+Y, X
      dpimm: /^#{HEX8},##{HEX8}$/i     # d, #i
      dpa: /^#{HEX8},a$/i              # d, A
      dprel: /^#{HEX8},#{HEX16}$/i     # d, r
      dpx: /^#{HEX8},x$/i              # d, X
      dpy: /^#{HEX8},y$/i              # d, Y
      dpya: /^#{HEX8},ya$/i            # d, YA
      dp0: /^#{HEX8}\.0$/i             # d.0
      dp0rel: /^#{HEX8}\.0,#{HEX16}$/i # d.0, r
      dp1: /^#{HEX8}\.1$/i             # d.1
      dp1rel: /^#{HEX8}\.1,#{HEX16}$/i # d.1, r
      dp2: /^#{HEX8}\.2$/i             # d.2
      dp2rel: /^#{HEX8}\.2,#{HEX16}$/i # d.2, r
      dp3: /^#{HEX8}\.3$/i             # d.3
      dp3rel: /^#{HEX8}\.3,#{HEX16}$/i # d.3, r
      dp4: /^#{HEX8}\.4$/i             # d.4
      dp4rel: /^#{HEX8}\.4,#{HEX16}$/i # d.4, r
      dp5: /^#{HEX8}\.5$/i             # d.5
      dp5rel: /^#{HEX8}\.5,#{HEX16}$/i # d.5, r
      dp6: /^#{HEX8}\.6$/i             # d.6
      dp6rel: /^#{HEX8}\.6,#{HEX16}$/i # d.6, r
      dp7: /^#{HEX8}\.7$/i             # d.7
      dp7rel: /^#{HEX8}\.7,#{HEX16}$/i # d.7, r
      ddds: /^#{HEX8}<d>,#{HEX8}<s>$/i # d<d>, d<s>
      mb: /^#{HEX16}\.([0-7])$/i    # m.b
      mbc: /^#{HEX16}\.([0-7]),c$/i # m.b, C
      psw: /^psw$/i        # PSW
      rel: /^#{HEX16}$/i   # r
      spx: /^sp,x$/i       # SP, X
      upage: /^#{HEX8}$/i  # u
      x: /^x$/i               # X
      xabs: /^x,#{HEX16}$/i   # X, !a
      ximm: /^x,##{HEX8}$/i   # X, #i
      xa: /^x,a$/i            # X, A
      xdp: /^x,#{HEX8}$/i     # X, d
      xdpy: /^x,#{HEX8}\+y$/i # X, d+Y
      xsp: /^x,sp$/i          # X, SP
      y: /^y$/i               # Y
      yabs: /^y,#{HEX16}$/i   # Y, !a
      yimm: /^y,##{HEX8}$/i   # Y, #i
      ya: /^y,a$/i            # Y, A
      ydp: /^y,#{HEX8}$/i     # Y, d
      ydpx: /^y,#{HEX8}\+x$/i # Y, d+X
      yrel: /^y,#{HEX16}$/i   # Y, r
      ya: /^ya$/i           # YA
      yadp: /^ya,#{HEX8}$/i # YA, d
      yax: /^ya,x$/i        # YA, X
    }

    MODES_FORMATS = {
      imp: "",
      abs: "!a",
      abspxa: "!a+X, A",
      abspya: "!a+Y, A",
      absa: "!a, A",
      absx: "!a, X",
      absy: "!a, Y",
      idxpacc: "(X)+, A",
      idxidy: "(X), (Y)",
      idxacc: "(X), A",
      t0: "0",
      t1: "1",
      t2: "2",
      t3: "3",
      t4: "4",
      t5: "5",
      t6: "6",
      t7: "7",
      t8: "8",
      t9: "9",
      t10: "10",
      t11: "11",
      t12: "12",
      t13: "13",
      t14: "14",
      t15: "15",
      absix: "[!a+X]",
      dpixacc: "[d+X], A",
      dpiyacc: "[d]+Y, A",
      acc: "A",
      accabs: "A, !a",
      accabsx: "A, !a+X",
      accabsy: "A, !a+Y",
      accimp: "A, #i",
      accidx: "A, (X)",
      accidxp: "A, (X)+",
      accdpix: "A, [d+X]",
      accdpiy: "A, [d]+Y",
      accdp: "A, d",
      accdpx: "A, d+X",
      accx: "A, X",
      accy: "A, Y",
      cnmb: "C, /m.b",
      cmb: "C, m.b",
      dp: "d",
      dppx: "d+X",
      dppxa: "d+X, A",
      dpxrel: "d+X, r",
      dppxy: "d+X, Y",
      dppyx: "d+Y, X",
      dpimm: "d, #i",
      dpa: "d, A",
      dprel: "d, r",
      dpx: "d, X",
      dpy: "d, Y",
      dpya: "d, YA",
      dp0: "d.0",
      dp0rel: "d.0, r",
      dp1: "d.1",
      dp1rel: "d.1, r",
      dp2: "d.2",
      dp2rel: "d.2, r",
      dp3: "d.3",
      dp3rel: "d.3, r",
      dp4: "d.4",
      dp4rel: "d.4, r",
      dp5: "d.5",
      dp5rel: "d.5, r",
      dp6: "d.6",
      dp6rel: "d.6, r",
      dp7: "d.7",
      dp7rel: "d.7, r",
      ddds: "dd, ds",
      mb: "m.b",
      mbc: "m.b, C",
      psw: "PSW",
      rel: "r",
      spx: "SP, X",
      upage: "u",
      x: "X",
      xabs: "X, !a",
      ximm: "X, #i",
      xa: "X, A",
      xdp: "X, d",
      xdpy: "X, d+Y",
      xsp: "X, SP",
      y: "Y",
      yabs: "Y, !a",
      yimm: "Y, #i",
      ya: "Y, A",
      ydp: "Y, d",
      ydpx: "Y, d+X",
      yrel: "Y, r",
      ya: "YA",
      yadp: "YA, d",
      yax: "YA, X"
    }

    OPCODES_DATA = [].freeze
  end
end
