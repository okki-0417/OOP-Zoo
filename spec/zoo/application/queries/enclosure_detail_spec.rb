# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::EnclosureDetail do
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
  let(:query) do
    lambda do |enclosure_id|
      command = commands::EnclosureDetailCommand.new(enclosure_id: enclosure_id)
                                                .bind(enclosures: enclosures, housings: housings)
      described_class.new(command: command).call
    end
  end

  describe '#call' do
    it '定員・収容数・清潔度・収容個体を含む詳細を返すこと' do
      profile = query.call(enclosure.id).value

      expect(profile.name).to eq('ライオンの丘')
      expect(profile.capacity).to eq(4)
      expect(profile.population).to eq(1)
      expect(profile.cleanliness).to eq(100)
      expect(profile.occupants.map(&:name)).to eq(['レオ'])
    end

    it "存在しない id 'missing' では EnclosureNotFound の失敗 Result を返すこと" do
      result = query.call('missing')

      expect(result).to be_failure
      expect(result.error).to be_a(Zoo::Application::Errors::EnclosureNotFound)
    end
  end
end
