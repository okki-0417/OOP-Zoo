# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::HireVeterinarian do
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:veterinarians) { in_memory::InMemoryVeterinarianRepository.new }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [veterinarians]) }
  let(:service) { described_class.new(veterinarians: veterinarians, unit_of_work: unit_of_work) }

  describe '#call' do
    it 'name を渡すと、採番された id で find できる獣医が保存されること' do
      vet = service.call(commands::HireVeterinarianCommand.new(name: '山田'))

      expect(veterinarians.find(vet.id)).to eq(vet)
      expect(vet.name).to eq('山田')
    end
  end
end
