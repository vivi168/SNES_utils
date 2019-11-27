require 'spec_helper'
require 'snes_utils'

describe SnesUtils::MiniAssembler do
  let(:mini_asm) { SnesUtils::MiniAssembler.new }
  let(:memory) do
    ["00", "11", "01", "11", "02", "11", "03", "11", "04", "11", "05", "11", "06", "11", "07", "11",
      "08", "09", "11", "0A", "0B", "0C", "22", "11", "0D", "22", "11", "0E", "22", "11", "0F", "33",
      "22", "11", "10", "11", "11", "11", "12", "11", "13", "11", "14", "11", "15", "11", "16", "11",
      "17", "11", "18", "19", "22", "11", "1A", "1B", "1C", "22", "11", "1D", "22", "11", "1E", "22",
      "11", "1F", "33", "22", "11", "20", "22", "11", "21", "11", "22", "33", "22", "11", "23", "11",
      "24", "11", "25", "11", "26", "11", "27", "11", "28", "29", "11", "2A", "2B", "2C", "22", "11",
      "2D", "22", "11", "2E", "22", "11", "2F", "33", "22", "11", "30", "11", "31", "11", "32", "11",
      "33", "11", "34", "11", "35", "11", "36", "11", "37", "11", "38", "39", "22", "11", "3A", "3B",
      "3C", "22", "11", "3D", "22", "11", "3E", "22", "11", "3F", "33", "22", "11", "40", "41", "11",
      "42", "11", "43", "11", "44", "22", "11", "45", "11", "46", "11", "47", "11", "48", "49", "11",
      "4A", "4B", "4C", "22", "11", "4D", "22", "11", "4E", "22", "11", "4F", "33", "22", "11", "50",
      "11", "51", "11", "52", "11", "53", "11", "54", "22", "11", "55", "11", "56", "11", "57", "11",
      "58", "59", "22", "11", "5A", "5B", "5C", "33", "22", "11", "5D", "22", "11", "5E", "22", "11",
      "5F", "33", "22", "11", "60", "61", "11", "62", "22", "11", "63", "11", "64", "11", "65", "11",
      "66", "11", "67", "11", "68", "69", "11", "6A", "6B", "6C", "22", "11", "6D", "22", "11", "6E",
      "22", "11", "6F", "33", "22", "11", "70", "11", "71", "11", "72", "11", "73", "11", "74", "11",
      "75", "11", "76", "11", "77", "11", "78", "79", "22", "11", "7A", "7B", "7C", "22", "11", "7D",
      "22", "11", "7E", "22", "11", "7F", "33", "22", "11", "80", "11", "81", "11", "82", "22", "11",
      "83", "11", "84", "11", "85", "11", "86", "11", "87", "11", "88", "89", "11", "8A", "8B", "8C",
      "22", "11", "8D", "22", "11", "8E", "22", "11", "8F", "33", "22", "11", "90", "11", "91", "11",
      "92", "11", "93", "11", "94", "11", "95", "11", "96", "11", "97", "11", "98", "99", "22", "11",
      "9A", "9B", "9C", "22", "11", "9D", "22", "11", "9E", "22", "11", "9F", "33", "22", "11", "A0",
      "11", "A1", "11", "A2", "11", "A3", "11", "A4", "11", "A5", "11", "A6", "11", "A7", "11", "A8",
      "A9", "11", "AA", "AB", "AC", "22", "11", "AD", "22", "11", "AE", "22", "11", "AF", "33", "22",
      "11", "B0", "11", "B1", "11", "B2", "11", "B3", "11", "B4", "11", "B5", "11", "B6", "11", "B7",
      "11", "B8", "B9", "22", "11", "BA", "BB", "BC", "22", "11", "BD", "22", "11", "BE", "22", "11",
      "BF", "33", "22", "11", "C0", "11", "C1", "11", "C2", "00", "C3", "11", "C4", "11", "C5", "11",
      "C6", "11", "C7", "11", "C8", "C9", "11", "CA", "CB", "CC", "22", "11", "CD", "22", "11", "CE",
      "22", "11", "CF", "33", "22", "11", "D0", "11", "D1", "11", "D2", "11", "D3", "11", "D4", "11",
      "D5", "11", "D6", "11", "D7", "11", "D8", "D9", "22", "11", "DA", "DB", "DC", "22", "11", "DD",
      "22", "11", "DE", "22", "11", "DF", "33", "22", "11", "E0", "11", "E1", "11", "E2", "00", "E3",
      "11", "E4", "11", "E5", "11", "E6", "11", "E7", "11", "E8", "E9", "11", "EA", "EB", "EC", "22",
      "11", "ED", "22", "11", "EE", "22", "11", "EF", "33", "22", "11", "F0", "11", "F1", "11", "F2",
      "11", "F3", "11", "F4", "22", "11", "F5", "11", "F6", "11", "F7", "11", "F8", "F9", "22", "11",
      "FA", "FB", "FC", "22", "11", "FD", "22", "11", "FE", "22", "11", "FF", "33", "22", "11"]
  end

  describe 'when assembling' do
    let(:file) { 'spec/fixtures/wdc65816.asm' }
    before { mini_asm.read(file) }

    it 'sets memory correctly' do
      expect(mini_asm.instance_variable_get(:@memory)).to eq memory
    end
  end

  describe 'when disassembling' do
    subject { mini_asm.disassemble_range(0, 256) }

    before do
      mini_asm.instance_variable_set(:@memory, memory)
      mini_asm.instance_variable_set(:@cpu, :wdc65816)
    end

    it 'disassembles correctly' do
      expect(subject).to eq [
        '00/0000: 00 11                 BRK 11',
        '00/0002: 01 11                 ORA (11,X)',
        '00/0004: 02 11                 COP 11',
        '00/0006: 03 11                 ORA 11,S',
        '00/0008: 04 11                 TSB 11',
        '00/000A: 05 11                 ORA 11',
        '00/000C: 06 11                 ASL 11',
        '00/000E: 07 11                 ORA [11]',
        '00/0010: 08                    PHP',
        '00/0011: 09 11                 ORA #11',
        '00/0013: 0A                    ASL',
        '00/0014: 0B                    PHD',
        '00/0015: 0C 22 11              TSB 1122',
        '00/0018: 0D 22 11              ORA 1122',
        '00/001B: 0E 22 11              ASL 1122',
        '00/001E: 0F 33 22 11           ORA 112233',
        '00/0022: 10 11                 BPL 0035 {+11}',
        '00/0024: 11 11                 ORA (11),Y',
        '00/0026: 12 11                 ORA (11)',
        '00/0028: 13 11                 ORA (11,S),Y',
        '00/002A: 14 11                 TRB 11',
        '00/002C: 15 11                 ORA 11,X',
        '00/002E: 16 11                 ASL 11,X',
        '00/0030: 17 11                 ORA [11],Y',
        '00/0032: 18                    CLC',
        '00/0033: 19 22 11              ORA 1122,Y',
        '00/0036: 1A                    INC',
        '00/0037: 1B                    TCS',
        '00/0038: 1C 22 11              TRB 1122',
        '00/003B: 1D 22 11              ORA 1122,X',
        '00/003E: 1E 22 11              ASL 1122,X',
        '00/0041: 1F 33 22 11           ORA 112233,X',
        '00/0045: 20 22 11              JSR 1122',
        '00/0048: 21 11                 AND (11,X)',
        '00/004A: 22 33 22 11           JSL 112233',
        '00/004E: 23 11                 AND 11,S',
        '00/0050: 24 11                 BIT 11',
        '00/0052: 25 11                 AND 11',
        '00/0054: 26 11                 ROL 11',
        '00/0056: 27 11                 AND [11]',
        '00/0058: 28                    PLP',
        '00/0059: 29 11                 AND #11',
        '00/005B: 2A                    ROL',
        '00/005C: 2B                    PLD',
        '00/005D: 2C 22 11              BIT 1122',
        '00/0060: 2D 22 11              AND 1122',
        '00/0063: 2E 22 11              ROL 1122',
        '00/0066: 2F 33 22 11           AND 112233',
        '00/006A: 30 11                 BMI 007D {+11}',
        '00/006C: 31 11                 AND (11),Y',
        '00/006E: 32 11                 AND (11)',
        '00/0070: 33 11                 AND (11,S),Y',
        '00/0072: 34 11                 BIT 11,X',
        '00/0074: 35 11                 AND 11,X',
        '00/0076: 36 11                 ROL 11,X',
        '00/0078: 37 11                 AND [11],Y',
        '00/007A: 38                    SEC',
        '00/007B: 39 22 11              AND 1122,Y',
        '00/007E: 3A                    DEC',
        '00/007F: 3B                    TSC',
        '00/0080: 3C 22 11              BIT 1122,X',
        '00/0083: 3D 22 11              AND 1122,X',
        '00/0086: 3E 22 11              ROL 1122,X',
        '00/0089: 3F 33 22 11           AND 112233,X',
        '00/008D: 40                    RTI',
        '00/008E: 41 11                 EOR (11,X)',
        '00/0090: 42 11                 WDM 11',
        '00/0092: 43 11                 EOR 11,S',
        '00/0094: 44 22 11              MVP 11,22',
        '00/0097: 45 11                 EOR 11',
        '00/0099: 46 11                 LSR 11',
        '00/009B: 47 11                 EOR [11]',
        '00/009D: 48                    PHA',
        '00/009E: 49 11                 EOR #11',
        '00/00A0: 4A                    LSR',
        '00/00A1: 4B                    PHK',
        '00/00A2: 4C 22 11              JMP 1122',
        '00/00A5: 4D 22 11              EOR 1122',
        '00/00A8: 4E 22 11              LSR 1122',
        '00/00AB: 4F 33 22 11           EOR 112233',
        '00/00AF: 50 11                 BVC 00C2 {+11}',
        '00/00B1: 51 11                 EOR (11),Y',
        '00/00B3: 52 11                 EOR (11)',
        '00/00B5: 53 11                 EOR (11,S),Y',
        '00/00B7: 54 22 11              MVN 11,22',
        '00/00BA: 55 11                 EOR 11,X',
        '00/00BC: 56 11                 LSR 11,X',
        '00/00BE: 57 11                 EOR [11],Y',
        '00/00C0: 58                    CLI',
        '00/00C1: 59 22 11              EOR 1122,Y',
        '00/00C4: 5A                    PHY',
        '00/00C5: 5B                    TCD',
        '00/00C6: 5C 33 22 11           JMP 112233',
        '00/00CA: 5D 22 11              EOR 1122,X',
        '00/00CD: 5E 22 11              LSR 1122,X',
        '00/00D0: 5F 33 22 11           EOR 112233,X',
        '00/00D4: 60                    RTS',
        '00/00D5: 61 11                 ADC (11,X)',
        '00/00D7: 62 22 11              PER 11FC {+1122}',
        '00/00DA: 63 11                 ADC 11,S',
        '00/00DC: 64 11                 STZ 11',
        '00/00DE: 65 11                 ADC 11',
        '00/00E0: 66 11                 ROR 11',
        '00/00E2: 67 11                 ADC [11]',
        '00/00E4: 68                    PLA',
        '00/00E5: 69 11                 ADC #11',
        '00/00E7: 6A                    ROR',
        '00/00E8: 6B                    RTL',
        '00/00E9: 6C 22 11              JMP (1122)',
        '00/00EC: 6D 22 11              ADC 1122',
        '00/00EF: 6E 22 11              ROR 1122',
        '00/00F2: 6F 33 22 11           ADC 112233',
        '00/00F6: 70 11                 BVS 0109 {+11}',
        '00/00F8: 71 11                 ADC (11),Y',
        '00/00FA: 72 11                 ADC (11)',
        '00/00FC: 73 11                 ADC (11,S),Y',
        '00/00FE: 74 11                 STZ 11,X',
        '00/0100: 75 11                 ADC 11,X',
        '00/0102: 76 11                 ROR 11,X',
        '00/0104: 77 11                 ADC [11],Y',
        '00/0106: 78                    SEI',
        '00/0107: 79 22 11              ADC 1122,Y',
        '00/010A: 7A                    PLY',
        '00/010B: 7B                    TDC',
        '00/010C: 7C 22 11              JMP (1122,X)',
        '00/010F: 7D 22 11              ADC 1122,X',
        '00/0112: 7E 22 11              ROR 1122,X',
        '00/0115: 7F 33 22 11           ADC 112233,X',
        '00/0119: 80 11                 BRA 012C {+11}',
        '00/011B: 81 11                 STA (11,X)',
        '00/011D: 82 22 11              BRL 1242 {+1122}',
        '00/0120: 83 11                 STA 11,S',
        '00/0122: 84 11                 STY 11',
        '00/0124: 85 11                 STA 11',
        '00/0126: 86 11                 STX 11',
        '00/0128: 87 11                 STA [11]',
        '00/012A: 88                    DEY',
        '00/012B: 89 11                 BIT #11',
        '00/012D: 8A                    TXA',
        '00/012E: 8B                    PHB',
        '00/012F: 8C 22 11              STY 1122',
        '00/0132: 8D 22 11              STA 1122',
        '00/0135: 8E 22 11              STX 1122',
        '00/0138: 8F 33 22 11           STA 112233',
        '00/013C: 90 11                 BCC 014F {+11}',
        '00/013E: 91 11                 STA (11),Y',
        '00/0140: 92 11                 STA (11)',
        '00/0142: 93 11                 STA (11,S),Y',
        '00/0144: 94 11                 STY 11,X',
        '00/0146: 95 11                 STA 11,X',
        '00/0148: 96 11                 STX 11,Y',
        '00/014A: 97 11                 STA [11],Y',
        '00/014C: 98                    TYA',
        '00/014D: 99 22 11              STA 1122,Y',
        '00/0150: 9A                    TXS',
        '00/0151: 9B                    TXY',
        '00/0152: 9C 22 11              STZ 1122',
        '00/0155: 9D 22 11              STA 1122,X',
        '00/0158: 9E 22 11              STZ 1122,X',
        '00/015B: 9F 33 22 11           STA 112233,X',
        '00/015F: A0 11                 LDY #11',
        '00/0161: A1 11                 LDA (11,X)',
        '00/0163: A2 11                 LDX #11',
        '00/0165: A3 11                 LDA 11,S',
        '00/0167: A4 11                 LDY 11',
        '00/0169: A5 11                 LDA 11',
        '00/016B: A6 11                 LDX 11',
        '00/016D: A7 11                 LDA [11]',
        '00/016F: A8                    TAY',
        '00/0170: A9 11                 LDA #11',
        '00/0172: AA                    TAX',
        '00/0173: AB                    PLB',
        '00/0174: AC 22 11              LDY 1122',
        '00/0177: AD 22 11              LDA 1122',
        '00/017A: AE 22 11              LDX 1122',
        '00/017D: AF 33 22 11           LDA 112233',
        '00/0181: B0 11                 BCS 0194 {+11}',
        '00/0183: B1 11                 LDA (11),Y',
        '00/0185: B2 11                 LDA (11)',
        '00/0187: B3 11                 LDA (11,S),Y',
        '00/0189: B4 11                 LDY 11,X',
        '00/018B: B5 11                 LDA 11,X',
        '00/018D: B6 11                 LDX 11,Y',
        '00/018F: B7 11                 LDA [11],Y',
        '00/0191: B8                    CLV',
        '00/0192: B9 22 11              LDA 1122,Y',
        '00/0195: BA                    TSX',
        '00/0196: BB                    TYX',
        '00/0197: BC 22 11              LDY 1122,X',
        '00/019A: BD 22 11              LDA 1122,X',
        '00/019D: BE 22 11              LDX 1122,Y',
        '00/01A0: BF 33 22 11           LDA 112233,X',
        '00/01A4: C0 11                 CPY #11',
        '00/01A6: C1 11                 CMP (11,X)',
        '00/01A8: C2 00                 REP #00',
        '00/01AA: C3 11                 CMP 11,S',
        '00/01AC: C4 11                 CPY 11',
        '00/01AE: C5 11                 CMP 11',
        '00/01B0: C6 11                 DEC 11',
        '00/01B2: C7 11                 CMP [11]',
        '00/01B4: C8                    INY',
        '00/01B5: C9 11                 CMP #11',
        '00/01B7: CA                    DEX',
        '00/01B8: CB                    WAI',
        '00/01B9: CC 22 11              CPY 1122',
        '00/01BC: CD 22 11              CMP 1122',
        '00/01BF: CE 22 11              DEC 1122',
        '00/01C2: CF 33 22 11           CMP 112233',
        '00/01C6: D0 11                 BNE 01D9 {+11}',
        '00/01C8: D1 11                 CMP (11),Y',
        '00/01CA: D2 11                 CMP (11)',
        '00/01CC: D3 11                 CMP (11,S),Y',
        '00/01CE: D4 11                 PEI 11',
        '00/01D0: D5 11                 CMP 11,X',
        '00/01D2: D6 11                 DEC 11,X',
        '00/01D4: D7 11                 CMP [11],Y',
        '00/01D6: D8                    CLD',
        '00/01D7: D9 22 11              CMP 1122,Y',
        '00/01DA: DA                    PHX',
        '00/01DB: DB                    STP',
        '00/01DC: DC 22 11              JMP [1122]',
        '00/01DF: DD 22 11              CMP 1122,X',
        '00/01E2: DE 22 11              DEC 1122,X',
        '00/01E5: DF 33 22 11           CMP 112233,X',
        '00/01E9: E0 11                 CPX #11',
        '00/01EB: E1 11                 SBC (11,X)',
        '00/01ED: E2 00                 SEP #00',
        '00/01EF: E3 11                 SBC 11,S',
        '00/01F1: E4 11                 CPX 11',
        '00/01F3: E5 11                 SBC 11',
        '00/01F5: E6 11                 INC 11',
        '00/01F7: E7 11                 SBC [11]',
        '00/01F9: E8                    INX',
        '00/01FA: E9 11                 SBC #11',
        '00/01FC: EA                    NOP',
        '00/01FD: EB                    XBA',
        '00/01FE: EC 22 11              CPX 1122',
        '00/0201: ED 22 11              SBC 1122',
        '00/0204: EE 22 11              INC 1122',
        '00/0207: EF 33 22 11           SBC 112233',
        '00/020B: F0 11                 BEQ 021E {+11}',
        '00/020D: F1 11                 SBC (11),Y',
        '00/020F: F2 11                 SBC (11)',
        '00/0211: F3 11                 SBC (11,S),Y',
        '00/0213: F4 22 11              PEA 1122',
        '00/0216: F5 11                 SBC 11,X',
        '00/0218: F6 11                 INC 11,X',
        '00/021A: F7 11                 SBC [11],Y',
        '00/021C: F8                    SED',
        '00/021D: F9 22 11              SBC 1122,Y',
        '00/0220: FA                    PLX',
        '00/0221: FB                    XCE',
        '00/0222: FC 22 11              JSR (1122,X)',
        '00/0225: FD 22 11              SBC 1122,X',
        '00/0228: FE 22 11              INC 1122,X',
        '00/022B: FF 33 22 11           SBC 112233,X'
      ]
    end
  end
end