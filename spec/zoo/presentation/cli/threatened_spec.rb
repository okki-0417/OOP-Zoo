# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Threatened do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  describe '#run' do
    it '絶滅危惧種がいなければ「展示中の絶滅危惧種はいません」を出力すること' do
      handler.run([])

      expect(output.string).to include('展示中の絶滅危惧種はいません')
    end

    it 'EN のグレビーシマウマ2頭を展示すると「グレビーシマウマ（EN/絶滅危惧）: 2頭」を出力すること' do
      enclosure = husbandry::Enclosure.new(name: 'サバンナ', temperature: shared::Temperature.celsius(30), capacity: 6)
      build_pair(catalog.grevys_zebra).each { |zebra| enclosure.admit(zebra) }
      container.enclosures.save(enclosure)

      handler.run([])

      expect(output.string).to include('グレビーシマウマ（EN/絶滅危惧）: 2頭')
    end
  end
end
