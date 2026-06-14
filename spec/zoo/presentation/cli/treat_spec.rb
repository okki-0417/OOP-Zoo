# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Treat do
  taxonomy = Zoo::Domain::Taxonomy
  staff    = Zoo::Domain::Staff
  medical  = Zoo::Domain::Medical

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  let(:vet) { staff::Veterinarian.new(name: '山田').tap { |v| container.veterinarians.save(v) } }
  let(:penguin) do
    build_adult(taxonomy::SpeciesCatalog.emperor_penguin, name: 'ペン').tap do |a|
      a.fall_ill(medical::IllnessCatalog.pneumonia)
      container.animals.save(a)
    end
  end

  describe '#run' do
    it 'VET_ID ANIMAL_ID を渡すと治療され、メッセージを出すこと' do
      handler.run([vet.id.to_s, penguin.id.to_s])

      expect(container.animals.find(penguin.id)).not_to be_sick
      expect(output.string).to include('治療しました', 'ペン')
    end

    it '引数不足だと ArgumentError(使い方) を上げること' do
      expect { handler.run([vet.id.to_s]) }.to raise_error(ArgumentError, /使い方/)
    end
  end
end
