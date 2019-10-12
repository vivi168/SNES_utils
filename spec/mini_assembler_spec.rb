require 'spec_helper'
require_relative '../mini_assembler/mini_assembler'

describe MiniAssembler do
  let(:mini_asm) { MiniAssembler.new }

  describe '#parse_address' do
    subject { mini_asm.parse_address(line) }

    context 'when address is given' do
      let(:line) { '300: lda #$12' }

      it 'returns the address given' do
        expect(subject).to eq(0x300)
      end
    end

    context 'when address is implied' do
      let(:line) { 'lda #$12' }

      it 'returns the current address' do
        expect(subject).to eq(0)
      end
    end
  end

  describe '#parse_instruction' do
    subject { mini_asm.parse_instruction(line) }
    context 'imm8' do
      let(:line) { 'ora #17' }

      it do
        expect(subject).to eq [['09', '17'], 2]
      end
    end

    context 'abs' do
      let(:line) { 'lda $1234' }

      it do
        expect(subject).to eq [['AD','34','12'], 3]
      end
    end

    context 'imp' do
      let(:line) { '300:xce' }

      it do
        expect(subject).to eq [['FB'], 1]
      end
    end

    context 'idly' do
      let(:line) { 'ADC [$12],Y' }

      it do
        expect(subject).to eq [['77', '12'], 2]
      end
    end

    describe 'relative addressing' do
      context '8 bit rel postivie' do
        let(:line) { '300:BMI 305' }

        it { expect(subject).to eq [['30', '03'], 2] }
      end

      context '8 bit rel negative' do
        let(:line) { '30a:bcc 300' }

        it { expect(subject).to eq [['90', 'f4'], 2] }
      end

      context '16 bit rel postivie' do
        let(:line) { '304:BRL $03A0' }

        it { expect(subject).to eq [['82', '99', '00'], 3] }
      end

      context '16 bit rel negative' do
        let(:line) { '3bf:per 37a' }

        it { expect(subject).to eq [['62', 'b8', 'ff'], 3] }
      end
    end
  end
end
