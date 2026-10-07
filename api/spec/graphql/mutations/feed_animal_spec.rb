# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::FeedAnimal do
  describe 'feedAnimal(animalId: "a1", keeperId: "k1", foodCode: "horse_meat")' do
    let!(:service) { stub_service(:feed_animal, Services::Result.success(:feed_animal, Object.new)) }

    before { OopZooSchema.execute('mutation { feedAnimal(animalId: "a1", keeperId: "k1", foodCode: "horse_meat") { __typename } }') }

    it 'animal_id: a1・keeper_id: k1・food_code: horse_meat の FeedAnimalCommand を Services::FeedAnimal に渡すこと' do
      expect(service).to have_received(:new).with(
        command: an_instance_of(Services::Commands::FeedAnimalCommand)
                 .and(having_attributes(animal_id: 'a1', keeper_id: 'k1', food_code: 'horse_meat'))
      )
    end
  end
end
