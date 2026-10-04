# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::FeedAnimal do
  taxonomy  = Zoo::Domain
  staff     = Zoo::Domain
  catalog   = taxonomy::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:mammal_keeper) { staff::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]) }
  let(:bird_keeper) { staff::Keeper.new(name: '鈴木', specialties: [taxonomy::TaxonClass.bird]) }

  let(:keepers) { in_memory::InMemoryKeeperRepository.new([mammal_keeper, bird_keeper]) }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:housings) { in_memory::InMemoryHousingRepository.new }
  let(:foods) { in_memory::InMemoryFoodRepository.new }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }

  def call_with(keeper_id:, animal_id:, food_code: 'horse_meat')
    command = Zoo::Application::Commands::FeedAnimalCommand.new(keeper_id:, animal_id:, food_code:)
                                                           .bind(keepers:, animals:, housings:, foods:, unit_of_work:)
    described_class.new(command: command).call
  end

  describe '#call' do
    it '空腹度40のライオンに food_code=\'horse_meat\'(満腹度35)を専門の飼育員が与えると hunger.level が5になること' do
      lion.get_hungrier(40)

      call_with(keeper_id: mammal_keeper.id, animal_id: lion.id)

      expect(animals.find(lion.id).hunger_level).to eq(5)
    end

    it '給餌に成功すると result.value が給餌後の hunger を持つ AnimalProfile になること' do
      lion.get_hungrier(40)

      result = call_with(keeper_id: mammal_keeper.id, animal_id: lion.id)

      expect(result.value).to be_a(Zoo::Application::ReadModels::AnimalProfile)
      expect(result.value).to have_attributes(id: lion.id.to_s, hunger: 5)
    end

    it '哺乳類のライオンに鳥類担当の飼育員が給餌しようとすると result.error が Domain::Errors::FeedingNotAllowed になること' do
      result = call_with(keeper_id: bird_keeper.id, animal_id: lion.id)

      expect(result.failure?).to be(true)
      expect(result.error).to be_a(Zoo::Domain::Errors::FeedingNotAllowed)
    end

    it '未知の food_code=\'dragon_fruit\' を渡すと result.error が Application::Errors::FoodNotFound になること' do
      result = call_with(keeper_id: mammal_keeper.id, animal_id: lion.id, food_code: 'dragon_fruit')

      expect(result.error).to be_a(Zoo::Application::Errors::FoodNotFound)
    end

    it '存在しない keeper_id=\'missing\' を渡すと result.error が Application::Errors::KeeperNotFound になること' do
      result = call_with(keeper_id: 'missing', animal_id: lion.id)

      expect(result.error).to be_a(Zoo::Application::Errors::KeeperNotFound)
    end

    it '存在しない animal_id=\'missing\' を渡すと result.error が Application::Errors::AnimalNotFound になること' do
      result = call_with(keeper_id: mammal_keeper.id, animal_id: 'missing')

      expect(result.error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
