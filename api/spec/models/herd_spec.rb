# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Herd do
  subject(:herd) { described_class.new(enclosure: build(:enclosure), species:, size:, crowded:) }

  let(:species) { SpeciesCatalog.grevys_zebra }
  let(:size) { 2 }
  let(:crowded) { false }

  describe '.in' do
    subject(:herds) { described_class.in(occupancy) }

    let(:occupancy) do
      Occupancy.new(
        enclosure: build(:enclosure, capacity: 8),
        occupants: [
          build(:animal, species: SpeciesCatalog.grevys_zebra), build(:animal, species: SpeciesCatalog.grevys_zebra),
          build(:animal, species: SpeciesCatalog.reticulated_giraffe)
        ]
      )
    end

    context '定員8のエリアにグレビーシマウマ2頭とアミメキリン1頭がいるとき' do
      it '種ごとの頭数 { グレビーシマウマ: 2, アミメキリン: 1 } の群れを返すこと' do
        expect(herds.to_h { |h| [h.species.name_ja, h.size] }).to eq('グレビーシマウマ' => 2, 'アミメキリン' => 1)
      end

      it 'どの群れも過密でないこと' do
        expect(herds.map(&:crowded?)).to eq([false, false])
      end
    end
  end

  describe '#multiplier' do
    context '群れ性のグレビーシマウマが1頭のとき' do
      let(:size) { 1 }

      it '1.0 を返すこと' do
        expect(herd.multiplier).to eq(1.0)
      end
    end

    context '群れ性のグレビーシマウマが2頭のとき' do
      it '1.25 を返すこと' do
        expect(herd.multiplier).to eq(1.25)
      end
    end

    context '群れ性のグレビーシマウマが3頭のとき' do
      let(:size) { 3 }

      it '1.375 を返すこと' do
        expect(herd.multiplier).to eq(1.375)
      end
    end

    context '群れ性のグレビーシマウマが4頭のとき' do
      let(:size) { 4 }

      it '1.4375 を返すこと' do
        expect(herd.multiplier).to eq(1.4375)
      end
    end

    context '群れ性のグレビーシマウマ2頭が過密なエリアにいるとき' do
      let(:crowded) { true }

      it '1.0 を返すこと' do
        expect(herd.multiplier).to eq(1.0)
      end
    end

    context '単独性のホッキョクグマが2頭のとき' do
      let(:species) { SpeciesCatalog.polar_bear }

      it '1.0 を返すこと' do
        expect(herd.multiplier).to eq(1.0)
      end
    end
  end

  describe '#appeal' do
    context '人気度60のグレビーシマウマが2頭のとき' do
      it '60 × 1.25 = 75.0 を返すこと' do
        expect(herd.appeal).to eq(75.0)
      end
    end
  end

  describe '#bonus' do
    context '人気度60のグレビーシマウマが2頭のとき' do
      it '75.0 - 60 = 15.0 を返すこと' do
        expect(herd.bonus).to eq(15.0)
      end
    end
  end

  describe '#crowded?' do
    context '過密なエリアにいるとき' do
      let(:crowded) { true }

      it 'true を返すこと' do
        expect(herd.crowded?).to be(true)
      end
    end
  end
end
