# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::FeedAnimal do
  taxonomy  = Zoo::Domain
  staff     = Zoo::Domain
  feeding   = Zoo::Domain
  catalog   = taxonomy::SpeciesCatalog
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:mammal_keeper) { staff::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]) }
  let(:bird_keeper) { staff::Keeper.new(name: '鈴木', specialties: [taxonomy::TaxonClass.bird]) }

  let(:keepers) { in_memory::InMemoryKeeperRepository.new([mammal_keeper, bird_keeper]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }
  let(:service) { described_class.new(keepers: keepers, animals: animals, unit_of_work: unit_of_work) }

  describe '#call' do
    it '空腹度40のライオンに満腹度35の馬肉を専門の飼育員が与えると hunger.level が5になること' do
      lion.get_hungrier(40)

      service.call(commands::FeedAnimalCommand.new(
                     keeper_id: mammal_keeper.id, animal_id: lion.id, food: feeding::FoodCatalog.horse_meat
                   ))

      expect(animals.find(lion.id).hunger.level).to eq(5)
    end

    it '哺乳類のライオンに鳥類担当の飼育員が給餌しようとすると Domain::Errors::NotQualified が伝播すること' do
      command = commands::FeedAnimalCommand.new(
        keeper_id: bird_keeper.id, animal_id: lion.id, food: feeding::FoodCatalog.horse_meat
      )

      expect { service.call(command) }.to raise_error(Zoo::Domain::Errors::NotQualified)
    end

    it '存在しない keeper_id=\'missing\' を渡すと Application::Errors::KeeperNotFound が発生すること' do
      command = commands::FeedAnimalCommand.new(
        keeper_id: 'missing', animal_id: lion.id, food: feeding::FoodCatalog.horse_meat
      )

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::KeeperNotFound)
    end

    it '存在しない animal_id=\'missing\' を渡すと Application::Errors::AnimalNotFound が発生すること' do
      command = commands::FeedAnimalCommand.new(
        keeper_id: mammal_keeper.id, animal_id: 'missing', food: feeding::FoodCatalog.horse_meat
      )

      expect { service.call(command) }.to raise_error(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
