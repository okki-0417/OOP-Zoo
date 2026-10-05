# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::HouseAnimal do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 2)
  end

  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:housings) { in_memory::InMemoryHousingRepository.new }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [enclosures, animals, housings]) }

  def call_with(enclosure_id:, animal_id:, enclosure_repo: enclosures)
    command = Zoo::Application::Commands::HouseAnimalCommand.new(enclosure_id:, animal_id:)
                                                            .bind(enclosures: enclosure_repo, animals:, housings:, unit_of_work:,
                                                                  assignments: Factory::AssignmentRepository.build)
    described_class.new(command: command).call
  end

  describe '#call' do
    it 'エリアと動物の id を渡すと、そのエリアの occupants にその動物が含まれること' do
      call_with(enclosure_id: enclosure.id, animal_id: lion.id)

      expect(occupants_of(housings, enclosure)).to include(lion)
    end

    it '収容に成功すると result.value の occupants がレオ1頭になること' do
      view = call_with(enclosure_id: enclosure.id, animal_id: lion.id).value

      expect(view[:enclosure]).to eq(enclosure)
      expect(view[:occupants].map(&:name)).to eq(['レオ'])
    end

    it '存在しない enclosure_id=\'missing\' を渡すと result.error が Application::Errors::EnclosureNotFound になること' do
      result = call_with(enclosure_id: 'missing', animal_id: lion.id)

      expect(result.error).to be_a(Zoo::Application::Errors::EnclosureNotFound)
    end

    it '存在しない animal_id=\'missing\' を渡すと result.error が Application::Errors::AnimalNotFound になること' do
      result = call_with(enclosure_id: enclosure.id, animal_id: 'missing')

      expect(result.error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end

    it '定員1の満員エリアに収容しようとすると result.error が定員を理由とする Domain::Errors::HousingNotAllowed になること' do
      resident = build_adult(catalog.lion, name: '先住')
      full = husbandry::Enclosure.new(name: '小屋', temperature: shared::Temperature.celsius(28), capacity: 1)
      housings.save(housed(resident, full))

      result = call_with(enclosure_id: full.id, animal_id: lion.id,
                         enclosure_repo: Zoo::Infrastructure::InMemory::InMemoryEnclosureRepository.new([full]))

      expect(result.error).to be_a(Zoo::Domain::Errors::HousingNotAllowed)
      expect(result.error.message).to match(/定員/)
    end
  end
end
