# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::TreatAnimal do
  describe 'treatAnimal(animalId: "a1", veterinarianId: "v1")' do
    it 'animal_id: a1・veterinarian_id: v1 の TreatAnimalCommand を Services::TreatAnimal に渡すこと' do
      service = stub_service(:treat_animal, Services::Result.success(:treat_animal, Object.new))

      OopZooSchema.execute('mutation { treatAnimal(animalId: "a1", veterinarianId: "v1") { __typename } }')

      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::TreatAnimalCommand).and(having_attributes(animal_id: 'a1', veterinarian_id: 'v1')))
    end
  end
end
