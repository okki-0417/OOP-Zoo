# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Enclosures do
  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  describe '#run' do
    it 'エリアが無ければ「エリアはありません」を出力すること' do
      handler.run([])

      expect(output.string).to include('エリアはありません')
    end

    it 'エリアがあれば id・名前・収容数/定員を出力すること' do
      container.enclosures.save(
        Zoo::Domain::Husbandry::Enclosure.new(
          name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4
        )
      )

      handler.run([])

      expect(output.string).to include('ライオンの丘（0/4）')
    end
  end
end
