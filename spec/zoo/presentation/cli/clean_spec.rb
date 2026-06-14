# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Clean do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  taxonomy  = Zoo::Domain::Taxonomy
  staff     = Zoo::Domain::Staff

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  let(:keeper) do
    staff::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]).tap { |k| container.keepers.save(k) }
  end
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
                        .tap { |e| e.soil(80); container.enclosures.save(e) }
  end

  describe '#run' do
    it 'KEEPER_ID ENCLOSURE_ID AMOUNT で清掃すると清潔度を反映して表示すること(20→50で70)' do
      handler.run([keeper.id.to_s, enclosure.id.to_s, '50'])

      expect(output.string).to include('清掃しました', '清潔度 70')
    end

    it 'AMOUNT 省略では100まで回復して表示すること' do
      handler.run([keeper.id.to_s, enclosure.id.to_s])

      expect(output.string).to include('清潔度 100')
    end
  end
end
