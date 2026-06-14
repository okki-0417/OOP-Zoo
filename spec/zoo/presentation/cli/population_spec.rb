# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Population do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  describe '#run' do
    it '在園0なら「在園数: 0頭」を出力すること' do
      handler.run([])

      expect(output.string).to include('在園数: 0頭')
    end

    it 'エリアに2頭収容されていれば「在園数: 2頭」を出力すること' do
      enclosure = husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
      build_pair(catalog.lion).each { |lion| enclosure.admit(lion) }
      container.enclosures.save(enclosure)

      handler.run([])

      expect(output.string).to include('在園数: 2頭')
    end
  end
end
