# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::DeceasedList do
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory
  commands  = Zoo::Application::Commands

  let(:animals) { in_memory::InMemoryAnimalRepository.new }
  let(:service) { described_class.new(command: commands::DeceasedListCommand.new.bind(animals: animals)) }

  describe '#call' do
    it '老衰で死んだレオを、集約のまま配列で返すこと' do
      lion = build_adult(catalog.lion, name: 'レオ')
      lion.die(cause: :old_age)
      animals.save(lion)

      expect(service.call.value.map(&:name)).to eq(['レオ'])
    end

    it '死亡が無ければ空配列を返すこと' do
      expect(service.call.value).to eq([])
    end
  end
end
