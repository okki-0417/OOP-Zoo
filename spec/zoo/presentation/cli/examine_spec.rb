# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Examine do
  taxonomy = Zoo::Domain::Taxonomy
  staff    = Zoo::Domain::Staff

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  let(:vet) { staff::Veterinarian.new(name: '山田').tap { |v| container.veterinarians.save(v) } }
  let(:lion) { build_adult(taxonomy::SpeciesCatalog.lion, name: 'レオ').tap { |a| container.animals.save(a) } }

  describe '#run' do
    it 'VET_ID ANIMAL_ID を渡すと健康な個体の診断「健康」を出力すること' do
      handler.run([vet.id.to_s, lion.id.to_s])

      expect(output.string).to include('診断: 健康')
    end

    it '引数不足だと ArgumentError(使い方) を上げること' do
      expect { handler.run([vet.id.to_s]) }.to raise_error(ArgumentError, /使い方/)
    end
  end
end
