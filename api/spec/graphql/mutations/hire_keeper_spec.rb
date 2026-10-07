# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::HireKeeper do
  describe 'hireKeeper(name: "田中", specialties: ["mammal", "bird"])' do
    let!(:service) { stub_service(:hire_keeper, Services::Result.success(:hire_keeper, Object.new)) }

    before { OopZooSchema.execute('mutation { hireKeeper(name: "田中", specialties: ["mammal", "bird"]) { __typename } }') }

    it 'name: 田中・specialties: [mammal, bird] の HireKeeperCommand を Services::HireKeeper に渡すこと' do
      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::HireKeeperCommand).and(having_attributes(name: '田中', specialties: %w[mammal bird])))
    end
  end
end
