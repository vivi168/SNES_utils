require 'spec_helper'
require_relative '../mini_assembler/mini_assembler'

describe MiniAssembler do
    describe 'modes' do
        subject { MiniAssembler.new.modes }
        
        it 'evaluates all mode correctly' do
            expect(subject.map { |k, v| v['regexp'] =~ v['example'] }.all?).to eq(true)
        end
    end
end