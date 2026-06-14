# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Open do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  def enclosure_with(animal)
    Zoo::Domain::Husbandry::Enclosure.new(
      name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4
    ).tap { |e| e.admit(animal) }
  end

  describe '#run' do
    it '誰も死なない開園では「開園しました。死亡: 0頭」を出力すること' do
      container.enclosures.save(enclosure_with(build_adult(catalog.lion, name: '若')))

      handler.run([])

      expect(output.string).to include('開園しました。死亡: 0頭')
    end

    it '寿命を超えた個体がいると「死亡: 1頭」と慰霊記録を出力すること' do
      container.enclosures.save(enclosure_with(build_animal(catalog.lion, name: '老', age_in_days: 1_000_000)))

      handler.run([])

      expect(output.string).to include('死亡: 1頭')
      expect(output.string).to include('老衰')
    end
  end
end
