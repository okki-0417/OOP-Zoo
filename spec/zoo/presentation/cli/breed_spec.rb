# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Breed do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  let(:pair) { build_pair(catalog.lion) }
  let(:sire) { pair[0].tap { |a| container.animals.save(a) } }
  let(:dam) { pair[1].tap { |a| container.animals.save(a) } }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
                        .tap { |e| container.enclosures.save(e) }
  end

  describe '#run' do
    it 'SIRE DAM ENCLOSURE NAME SEX を渡すと子が誕生し、誕生メッセージを出すこと' do
      handler.run([sire.id.to_s, dam.id.to_s, enclosure.id.to_s, 'シンバ', 'male'])

      expect(output.string).to include('誕生しました', 'シンバ')
      expect(container.birth_announcements.announcements.size).to eq(1)
    end

    it '引数不足だと ArgumentError(使い方) を上げること' do
      expect { handler.run([sire.id.to_s, dam.id.to_s]) }.to raise_error(ArgumentError, /使い方/)
    end
  end
end
