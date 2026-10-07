# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::HireVeterinarian do
  describe 'hireVeterinarian(name: "山田")' do
    it 'name: 山田 の HireVeterinarianCommand を Services::HireVeterinarian に渡すこと' do
      service = stub_service(:hire_veterinarian, Services::Result.success(:hire_veterinarian, Object.new))

      OopZooSchema.execute('mutation { hireVeterinarian(name: "山田") { __typename } }')

      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::HireVeterinarianCommand).and(having_attributes(name: '山田')))
    end
  end
end
