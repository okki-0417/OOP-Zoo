# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Report do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  describe '#run' do
    it '在園・収益などの統計を整形して出力すること' do
      container.enclosures.save(
        husbandry::Enclosure.new(name: 'サバンナ', temperature: shared::Temperature.celsius(30), capacity: 6)
                            .tap { |e| e.admit(build_adult(catalog.grevys_zebra, name: 'シマオ')) }
      )

      handler.run([])

      expect(output.string).to include('在園数: 1頭（1種）', '絶滅危惧種: 1種', '累計収益: ¥0')
    end
  end
end
