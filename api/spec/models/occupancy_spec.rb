# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Occupancy do
  subject(:occupancy) { described_class.new(enclosure:, occupants:) }

  let(:enclosure) { build(:enclosure, capacity:) }
  let(:capacity) { 4 }
  let(:occupants) { [] }
  let(:zebra) { build(:animal, species: SpeciesCatalog.grevys_zebra) }
  let(:giraffe) { build(:animal, species: SpeciesCatalog.reticulated_giraffe) }

  describe '#full?' do
    let(:capacity) { 2 }

    context '定員2にグレビーシマウマ1頭のとき' do
      let(:occupants) { [zebra] }

      it 'false を返すこと' do
        expect(occupancy.full?).to be(false)
      end
    end

    context '定員2にグレビーシマウマ2頭のとき' do
      let(:occupants) { [zebra, build(:animal, species: SpeciesCatalog.grevys_zebra)] }

      it 'true を返すこと' do
        expect(occupancy.full?).to be(true)
      end
    end
  end

  describe '#species_present_in' do
    context 'グレビーシマウマとアミメキリンがいるとき' do
      let(:occupants) { [zebra, giraffe] }

      it '2種を返すこと' do
        expect(occupancy.species_present_in.size).to eq(2)
      end
    end
  end

  describe '#required_area' do
    context 'グレビーシマウマ2頭のとき' do
      let(:occupants) { [zebra, build(:animal, species: SpeciesCatalog.grevys_zebra)] }

      it '必要面積の合計 200.0 を返すこと' do
        expect(occupancy.required_area).to eq(200.0)
      end
    end
  end

  describe '#overcrowded?' do
    context '定員2の空のエリアのとき' do
      let(:capacity) { 2 }

      it 'false を返すこと' do
        expect(occupancy.overcrowded?).to be(false)
      end
    end

    context '定員1のエリアにアミメキリンがいて必要面積が広さを超えるとき' do
      let(:capacity) { 1 }
      let(:occupants) { [giraffe] }

      it 'true を返すこと' do
        expect(occupancy.overcrowded?).to be(true)
      end
    end
  end
end
