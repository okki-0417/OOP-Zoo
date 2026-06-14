# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Transfer do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  let(:lion) { build_adult(catalog.lion, name: 'レオ').tap { |a| container.animals.save(a) } }
  let(:from) do
    husbandry::Enclosure.new(name: '丘A', temperature: shared::Temperature.celsius(28), capacity: 4)
                        .tap { |e| e.admit(lion); container.enclosures.save(e) }
  end
  let(:to) do
    husbandry::Enclosure.new(name: '丘B', temperature: shared::Temperature.celsius(28), capacity: 4)
                        .tap { |e| container.enclosures.save(e) }
  end

  describe '#run' do
    it 'ANIMAL_ID TO_ENCLOSURE_ID を渡すと移送され、移送メッセージを出すこと' do
      from # 先住エリアを用意
      handler.run([lion.id.to_s, to.id.to_s])

      expect(container.enclosures.find(to.id).occupants).to include(lion)
      expect(output.string).to include('移送しました', '丘B')
    end

    it '引数不足だと ArgumentError(使い方) を上げること' do
      expect { handler.run([lion.id.to_s]) }.to raise_error(ArgumentError, /使い方/)
    end
  end
end
