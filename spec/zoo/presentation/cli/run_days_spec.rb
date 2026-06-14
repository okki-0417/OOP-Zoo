# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::RunDays do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  describe '#run' do
    it 'DAYS を渡すと指定日数進め、経過日数と死亡数を出力すること' do
      survivor = build_adult(catalog.lion, name: '若')
      container.animals.save(survivor)
      container.enclosures.save(
        husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
                            .tap { |e| e.admit(survivor) }
      )

      handler.run(['5'])

      expect(output.string).to include('5日経過。死亡: 0頭')
    end

    it '数値でない DAYS を渡すと ArgumentError を上げること' do
      expect { handler.run(['たくさん']) }.to raise_error(ArgumentError)
    end
  end
end
