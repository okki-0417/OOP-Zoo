# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AnimalDetail do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory
  commands  = Zoo::Application::Commands

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new }
  let(:housings) { in_memory::InMemoryHousingRepository.new }
  let(:service) do
    lambda do |animal_id|
      command = commands::AnimalDetailCommand.new(animal_id: animal_id).bind(animals: animals, housings: housings)
      described_class.new(command: command).call
    end
  end

  describe '#call' do
    it '未収容のレオの id を渡すと { animal: レオ, enclosure: nil } を返すこと' do
      expect(service.call(lion.id).value).to eq(animal: lion, enclosure: nil)
    end

    it 'サバンナに収容中のレオの id を渡すと enclosure にサバンナを返すこと' do
      enclosure = husbandry::Enclosure.new(
        name: 'サバンナ', temperature: shared::Temperature.celsius(28), capacity: 4
      )
      enclosures.save(enclosure)
      housings.save(housed(lion, enclosure))

      expect(service.call(lion.id).value).to eq(animal: lion, enclosure: enclosure)
    end

    it "存在しない id 'missing' を渡すと AnimalNotFound の失敗 Result を返すこと" do
      result = service.call('missing')

      expect(result).to be_failure
      expect(result.error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
