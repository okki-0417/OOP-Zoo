# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::AcquireAnimal do
  describe 'acquireAnimal(speciesCode: "lion", name: "レオ", sex: MALE)' do
    let!(:service) { stub_service(:acquire_animal, Services::Result.success(:acquire_animal, Object.new)) }

    before { OopZooSchema.execute('mutation { acquireAnimal(speciesCode: "lion", name: "レオ", sex: MALE) { __typename } }') }

    it 'species_code: lion・name: レオ・sex: :male の AcquireAnimalCommand を Services::AcquireAnimal に渡すこと' do
      expect(service).to have_received(:new).with(
        command: an_instance_of(Services::Commands::AcquireAnimalCommand)
                 .and(having_attributes(species_code: 'lion', name: 'レオ', sex: :male))
      )
    end
  end
end
