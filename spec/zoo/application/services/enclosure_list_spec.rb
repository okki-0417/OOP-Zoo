# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::EnclosureList do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory
  commands  = Zoo::Application::Commands

  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:housings) do
    in_memory::InMemoryHousingRepository.new([housed(build_adult(catalog.lion, name: 'レオ'), enclosure)])
  end

  let(:service) do
    described_class.new(command: commands::EnclosureListCommand.new.bind(
      enclosures:, housings:, assignments: Factory::AssignmentRepository.build
    ))
  end

  describe '#call' do
    it 'エリアごとに { enclosure:, occupants:, keepers: } を返し、ライオンの丘の occupants がレオであること' do
      view = service.call.value.first

      expect(view[:enclosure]).to eq(enclosure)
      expect(view[:occupants].map(&:name)).to eq(['レオ'])
      expect(view[:keepers]).to eq([])
    end
  end
end
