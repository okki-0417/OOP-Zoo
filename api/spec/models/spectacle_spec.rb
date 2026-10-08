# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spectacle do
  subject(:spectacle) { described_class.new(herds:, buzzes:) }

  let(:zebra) { SpeciesCatalog.grevys_zebra }
  let(:lion) { SpeciesCatalog.lion }
  let(:zebras) { Herd.new(enclosure: build(:enclosure), species: zebra, size: 2, crowded: false) }
  let(:lions) { Herd.new(enclosure: build(:enclosure), species: lion, size: 1, crowded: false) }
  let(:herds) { [zebras, lions] }
  let(:buzzes) { [] }

  describe '.of' do
    subject(:spectacle) { described_class.of([occupancy], today: 10) }

    let(:occupancy) do
      Occupancy.new(
        enclosure: build(:enclosure, capacity: 4),
        occupants: [build(:animal, species: zebra), build(:animal, species: zebra, acquiring: Acquiring.new(day: 10))]
      )
    end

    context '定員4のエリアにグレビーシマウマ2頭がいて、うち1頭が今日導入されたとき' do
      it '2頭の群れ1つを返すこと' do
        expect(spectacle.herds.map(&:size)).to eq([2])
      end

      it '話題として新入り1頭だけを返すこと' do
        expect(spectacle.buzzes.map(&:kind)).to eq([:newcomer])
      end
    end
  end

  describe '#herds' do
    context 'グレビーシマウマが2つのエリアに1頭と3頭いるとき' do
      let(:herds) do
        [
          Herd.new(enclosure: build(:enclosure), species: zebra, size: 1, crowded: false),
          Herd.new(enclosure: build(:enclosure), species: zebra, size: 3, crowded: false)
        ]
      end

      it '見応えが大きい3頭の群れだけを返すこと' do
        expect(spectacle.herds.map(&:size)).to eq([3])
      end
    end
  end

  describe '#charisma' do
    context 'グレビーシマウマ(60)2頭とライオン(90)1頭のとき' do
      it '種ごとに1回だけ数えて 150 を返すこと' do
        expect(spectacle.charisma).to eq(150)
      end
    end
  end

  describe '#herd_bonus' do
    context 'グレビーシマウマ(60)2頭とライオン(90)1頭のとき' do
      it 'シマウマの群れの分 15.0 を返すこと' do
        expect(spectacle.herd_bonus).to eq(15.0)
      end
    end
  end

  describe '#buzz' do
    context '生後0日のグレビーシマウマが1頭いるとき' do
      let(:buzzes) do
        [Buzz.new(animal: build(:animal, species: zebra, dam: build(:animal, :female, species: zebra), age_in_days: 0), today: 0)]
      end

      it '30.0 を返すこと' do
        expect(spectacle.buzz).to eq(30.0)
      end
    end
  end

  describe '#value' do
    context 'グレビーシマウマ(60)2頭とライオン(90)1頭のとき' do
      it '150 + 15 = 165 を上限3,000に向けて頭打ちにした 3000×165/3165 を返すこと' do
        expect(spectacle.value).to be_within(0.001).of(3000.0 * 165 / 3165)
      end
    end

    context '群れも話題もないとき' do
      let(:herds) { [] }

      it '0.0 を返すこと' do
        expect(spectacle.value).to eq(0.0)
      end
    end
  end
end
