# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AcquireAnimal do
  animal    = Zoo::Domain::Animal
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:animals) { in_memory::InMemoryAnimalRepository.new }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }
  let(:service) { described_class.new(animals: animals, unit_of_work: unit_of_work) }

  describe '#call' do
    it 'ライオン・名前\'レオ\'・オス・max_health=100 を渡すと、採番された id で find できる個体が保存されること' do
      acquired = service.call(commands::AcquireAnimalCommand.new(
                                species: catalog.lion, name: 'レオ', sex: animal::Sex.male, max_health: 100
                              ))

      expect(acquired.id).not_to be_nil
      expect(animals.find(acquired.id)).to eq(acquired)
      expect(acquired.name.to_s).to eq('レオ')
    end

    it 'age_in_days 省略で取得した個体は age_in_days.value が0であること' do
      acquired = service.call(commands::AcquireAnimalCommand.new(
                                species: catalog.lion, name: 'レオ', sex: animal::Sex.male, max_health: 100
                              ))

      expect(acquired.age_in_days.value).to eq(0)
    end
  end
end
