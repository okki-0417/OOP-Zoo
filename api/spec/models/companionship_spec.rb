# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Companionship do
  subject(:companionship) do
    described_class.new(enclosure:, occupancy: Occupancy.new(enclosure:, occupants:), member:)
  end

  let(:enclosure) { build(:enclosure, capacity: 6) }

  describe '#subordinate_male?' do
    context '成熟オスの長老(4000日齢)と若が同居しているとき' do
      let(:senior) { build(:animal, name: '長老', age_in_days: 4000) }
      let(:junior) { build(:animal, name: '若') }
      let(:occupants) { [senior, junior] }

      context 'member が若のとき' do
        let(:member) { junior }

        it 'true を返すこと' do
          expect(companionship.subordinate_male?).to be(true)
        end
      end

      context 'member が長老のとき' do
        let(:member) { senior }

        it 'false を返すこと' do
          expect(companionship.subordinate_male?).to be(false)
        end
      end
    end

    context 'オス1頭・メス・仔が同居しているとき' do
      let(:male) { build(:animal) }
      let(:female) { build(:animal, :female) }
      let(:cub) { build(:animal, :newborn) }
      let(:occupants) { [male, female, cub] }

      context 'member がオスのとき' do
        let(:member) { male }

        it 'false を返すこと' do
          expect(companionship.subordinate_male?).to be(false)
        end
      end

      context 'member がメスのとき' do
        let(:member) { female }

        it 'false を返すこと' do
          expect(companionship.subordinate_male?).to be(false)
        end
      end

      context 'member が未成熟の仔のとき' do
        let(:member) { cub }

        it 'false を返すこと' do
          expect(companionship.subordinate_male?).to be(false)
        end
      end
    end
  end

  describe '#injury' do
    context '序列下位でないグレビーシマウマ1頭のとき' do
      let(:member) { build(:animal, species: SpeciesCatalog.grevys_zebra) }
      let(:occupants) { [member] }

      it '0 を返すこと' do
        expect(companionship.injury).to eq(0)
      end
    end

    context '序列下位の若が、長老(4000日齢)と同居しているとき' do
      let(:member) { build(:animal, name: '若') }
      let(:occupants) { [build(:animal, name: '長老', age_in_days: 4000), member] }
      let(:roomy) { build(:enclosure, capacity: 6) }
      let(:spacious) { described_class.new(enclosure: roomy, occupancy: Occupancy.new(enclosure: roomy, occupants:), member:) }

      context '定員4・1m²で遊具が枯れた狭いエリアのとき' do
        let(:enclosure) { build(:enclosure, capacity: 4, area_sqm: 1).tap { |e| e.deplete_enrichment(100) } }

        it '定員6の広いエリアより大きい外傷を返すこと' do
          expect(companionship.injury).to be > spacious.injury
        end
      end
    end
  end

  describe '#lonely?' do
    let(:member) { build(:animal) }

    context '群れ性のライオンが1頭だけのとき' do
      let(:occupants) { [member] }

      it 'true を返すこと' do
        expect(companionship.lonely?).to be(true)
      end
    end

    context '同種のメスと同居しているとき' do
      let(:occupants) { [member, build(:animal, :female)] }

      it 'false を返すこと' do
        expect(companionship.lonely?).to be(false)
      end
    end
  end

  describe '#separated_dependent?' do
    let(:occupants) { [member] }

    context '未離乳の仔が、母と同居していないとき' do
      let(:member) { build(:animal, :newborn, dam: build(:animal, :female, name: '母')) }

      it 'true を返すこと' do
        expect(companionship.separated_dependent?).to be(true)
      end
    end

    context '離乳済みの成獣のとき' do
      let(:member) { build(:animal) }

      it 'false を返すこと' do
        expect(companionship.separated_dependent?).to be(false)
      end
    end
  end
end
