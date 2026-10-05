# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AnimalList do
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory
  commands  = Zoo::Application::Commands

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:animals) { in_memory::InMemoryAnimalRepository.new([lion]) }
  let(:service) { described_class.new(command: commands::AnimalListCommand.new.bind(animals: animals)) }

  describe '#call' do
    it '登録済みの個体(レオ)を集約のまま配列で返すこと' do
      expect(service.call.value).to eq([lion])
    end
  end
end
