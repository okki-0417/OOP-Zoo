# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Commands::HouseAnimalCommand do
  describe '.new' do
    it 'enclosure_id=\'e1\'・animal_id=\'a1\' を渡すと各値を読み出せること' do
      command = described_class.new(enclosure_id: 'e1', animal_id: 'a1')

      expect(command.enclosure_id).to eq('e1')
      expect(command.animal_id).to eq('a1')
    end

    it 'enclosure_id=nil で生成すると ArgumentError が発生すること' do
      expect { described_class.new(enclosure_id: nil, animal_id: 'a1') }
        .to raise_error(ArgumentError)
    end

    it 'animal_id=nil で生成すると ArgumentError が発生すること' do
      expect { described_class.new(enclosure_id: 'e1', animal_id: nil) }
        .to raise_error(ArgumentError)
    end
  end
end
