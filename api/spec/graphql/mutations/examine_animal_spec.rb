# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::ExamineAnimal do
  describe 'examineAnimal(animalId: "a1", veterinarianId: "v1")' do
    it 'animal_id: a1・veterinarian_id: v1 の ExamineAnimalCommand を Services::ExamineAnimal に渡すこと' do
      service = stub_service(:examine_animal, Services::Result.success(:examine_animal, Object.new))

      OopZooSchema.execute('mutation { examineAnimal(animalId: "a1", veterinarianId: "v1") { __typename } }')

      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::ExamineAnimalCommand).and(having_attributes(animal_id: 'a1', veterinarian_id: 'v1')))
    end
  end
end
