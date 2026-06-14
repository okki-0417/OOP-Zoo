# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Feed do
  taxonomy = Zoo::Domain::Taxonomy
  staff    = Zoo::Domain::Staff

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  let(:keeper) do
    staff::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]).tap { |k| container.keepers.save(k) }
  end
  let(:lion) { build_adult(taxonomy::SpeciesCatalog.lion, name: 'レオ').tap { |a| container.animals.save(a) } }

  describe '#run' do
    it 'KEEPER_ID ANIMAL_ID FOOD を渡すと給餌され、空腹度を表示すること' do
      lion.get_hungrier(40)

      handler.run([keeper.id.to_s, lion.id.to_s, 'horse_meat'])

      expect(output.string).to include('給餌しました', 'レオ')
    end

    it "未知の餌 'pizza' を渡すと ArgumentError(未知の餌) を上げること" do
      expect { handler.run([keeper.id.to_s, lion.id.to_s, 'pizza']) }
        .to raise_error(ArgumentError, /未知の餌/)
    end

    it '引数不足だと ArgumentError(使い方) を上げること' do
      expect { handler.run([keeper.id.to_s, lion.id.to_s]) }.to raise_error(ArgumentError, /使い方/)
    end
  end
end
