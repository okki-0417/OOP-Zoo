# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::FeedAnimal do
  catalog = Zoo::Domain::SpeciesCatalog

  let!(:lion) { build_adult(catalog.lion, name: 'レオ').get_hungrier(40).tap(&:save!) }
  let!(:mammal_keeper) { Zoo::Domain::Keeper.create!(name: '田中', specialties: [Zoo::Domain::TaxonClass.mammal]) }
  let!(:bird_keeper) { Zoo::Domain::Keeper.create!(name: '鈴木', specialties: [Zoo::Domain::TaxonClass.bird]) }

  def call_with(keeper_id:, animal_id:, food_code: 'horse_meat')
    command = Zoo::Application::Commands::FeedAnimalCommand.new(keeper_id:, animal_id:, food_code:)
    described_class.new(command:).call
  end

  describe '#call' do
    it '空腹度40のライオンに food_code=\'horse_meat\'(満腹度35)を専門の飼育員が与えると保存された hunger_level が5になること' do
      call_with(keeper_id: mammal_keeper.id, animal_id: lion.id)

      expect(lion.reload.hunger_level).to eq(5)
    end

    it '給餌に成功すると result.value が給餌後の hunger_level 5 になること' do
      result = call_with(keeper_id: mammal_keeper.id, animal_id: lion.id)

      expect(result.value).to eq(lion)
      expect(result.value.hunger_level).to eq(5)
    end

    it '哺乳類のライオンに鳥類担当の飼育員が給餌しようとすると result.error が Domain::Errors::FeedingNotAllowed になり空腹度40のままであること' do
      result = call_with(keeper_id: bird_keeper.id, animal_id: lion.id)

      expect(result.failure?).to be(true)
      expect(result.error).to be_a(Zoo::Domain::Errors::FeedingNotAllowed)
      expect(lion.reload.hunger_level).to eq(40)
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
