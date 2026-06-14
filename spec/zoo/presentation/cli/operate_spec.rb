# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Operate do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  describe '#run' do
    it '1日運営すると来園・収支・評判・残高の2行を出力すること' do
      zebra = build_adult(catalog.grevys_zebra, name: 'シマオ')
      container.animals.save(zebra)
      container.enclosures.save(
        husbandry::Enclosure.new(name: 'サバンナ', temperature: shared::Temperature.celsius(30), capacity: 6)
                            .tap { |e| e.admit(zebra) }
      )

      handler.run([])

      expect(output.string).to include('来園', '収入', '費用')
      expect(output.string).to include('評判', '残高')
    end
  end
end
