# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::HireKeeper do
  describe 'hireKeeper(name: "田中", specialties: ["mammal", "bird"])' do
    it 'name: 田中・specialties: [mammal, bird] の HireKeeperCommand を Services::HireKeeper に渡すこと' do
      service = stub_service(:hire_keeper, Services::Result.success(:hire_keeper, Object.new))

      OopZooSchema.execute('mutation { hireKeeper(name: "田中", specialties: ["mammal", "bird"]) { __typename } }')

      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::HireKeeperCommand).and(having_attributes(name: '田中', specialties: %w[mammal bird])))
    end
  end
end
