# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::RenameAnimal do
  describe 'renameAnimal(animalId: "a1", newName: "シンバ")' do
    it 'animal_id: a1・new_name: シンバ の RenameAnimalCommand を Services::RenameAnimal に渡すこと' do
      service = stub_service(:rename_animal, Services::Result.success(:rename_animal, Object.new))

      OopZooSchema.execute('mutation { renameAnimal(animalId: "a1", newName: "シンバ") { __typename } }')

      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::RenameAnimalCommand).and(having_attributes(animal_id: 'a1', new_name: 'シンバ')))
    end
  end
end
