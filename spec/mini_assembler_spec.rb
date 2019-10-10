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
    context 'imm' do
      let(:line) { 'ora #17' }

      it do
        expect(subject).to eq ['09', '17']
      end
    end

    context 'abs' do
      let(:line) { 'lda $1234' }

      it do
        expect(subject).to eq ['AD','34','12']
      end
    end

    context 'imp' do
      let(:line) { '300:xce' }

      it do
        expect(subject).to eq ['FB']
      end
    end

    context 'idly' do
      let(:line) { 'ADC [$12],Y' }

      it do
        expect(subject).to eq ['77', '12']
      end
    end
  end
end
