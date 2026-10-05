# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::EnclosureDetail do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory
  commands  = Zoo::Application::Commands

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
  end
  let(:enclosures) { in_memory::InMemoryEnclosureRepository.new([enclosure]) }
  let(:housings) { in_memory::InMemoryHousingRepository.new([housed(lion, enclosure)]) }
  let(:service) do
    lambda do |enclosure_id|
      command = commands::EnclosureDetailCommand.new(enclosure_id: enclosure_id)
                                                .bind(enclosures: enclosures, housings: housings,
                                                      assignments: Factory::AssignmentRepository.build)
      described_class.new(command: command).call
    end
  end

  describe '#call' do
    it 'エリアの id を渡すと { enclosure: ライオンの丘, occupants: [レオ], keepers: [] } を返すこと' do
      view = service.call(enclosure.id).value

      expect(view[:enclosure]).to eq(enclosure)
      expect(view[:occupants].map(&:name)).to eq(['レオ'])
      expect(view[:keepers]).to eq([])
    end

    it "存在しない id 'missing' では EnclosureNotFound の失敗 Result を返すこと" do
      result = service.call('missing')

      expect(result).to be_failure
      expect(result.error).to be_a(Zoo::Application::Errors::EnclosureNotFound)
    end
  end
end
