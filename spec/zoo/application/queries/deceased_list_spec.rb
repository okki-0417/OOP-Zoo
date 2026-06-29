# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::DeceasedList do
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:animals) { in_memory::InMemoryAnimalRepository.new }
  let(:query) { described_class.new(animals: animals) }

  describe '#call' do
    it '死亡した動物を死因つきの慰霊記録として返すこと' do
      lion = build_adult(catalog.lion, name: 'レオ')
      lion.die(cause: :old_age)
      animals.save(lion)

      record = query.call.first

      expect(record.name).to eq('レオ')
      expect(record.species).to eq('ライオン')
      expect(record.cause).to eq(:old_age)
    end

    it '死亡が無ければ空配列を返すこと' do
      expect(query.call).to eq([])
    end
  end
end
