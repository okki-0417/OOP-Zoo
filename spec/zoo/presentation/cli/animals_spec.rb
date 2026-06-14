# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Animals do
  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  describe '#run' do
    it '個体が無ければ「個体はいません」を出力すること' do
      handler.run([])

      expect(output.string).to include('個体はいません')
    end

    it '個体がいれば id・名前・種を出力すること' do
      container.animals.save(build_adult(Zoo::Domain::Taxonomy::SpeciesCatalog.lion, name: 'レオ'))

      handler.run([])

      expect(output.string).to include('レオ（ライオン）')
    end
  end
end
