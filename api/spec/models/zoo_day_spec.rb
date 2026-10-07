# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ZooDay do
  subject(:zoo_day) do
    described_class.new(
      zoo:, occupancies: [Occupancy.new(enclosure: hill, occupants:)], keepers: [keeper], veterinarians: [],
      yesterday:, random: Random.new(0)
    )
  end

  let(:zoo) { build(:zoo) }
  let(:hill) { build(:enclosure, name: '丘') }
  let(:lion) { build(:animal, name: 'レオ') }
  let(:occupants) { [lion] }
  let(:keeper) { build(:keeper) }
  let(:yesterday) { nil }

  describe '#run' do
    subject(:operating) { zoo_day.run }

    it 'zoo.day を1にし、day=1 の Operating を返すこと' do
      expect(operating).to be_a(Operating).and have_attributes(day: 1)
      expect(zoo.day).to eq(1)
    end

    it 'expenses に payroll・upkeep・feed が並び、cost がその合計であること' do
      expect(operating.expenses.map { |expense| expense.category.value }).to contain_exactly(:payroll, :upkeep, :feed)
      expect(operating.cost).to eq(Money.yen(operating.expenses.sum { |expense| expense.amount.yen }))
    end

    it '丘はレオ1頭ぶん汚れて cleanliness_level=99、刺激が2減って enrichment=98 になること' do
      operating

      expect(hill.cleanliness_level).to eq(99)
      expect(hill.enrichment.level).to eq(98)
    end

    context '前日の累計(visitor_count・revenue が実行前の園と同じ)があるとき' do
      let(:yesterday) { Operating.new(total_visitors: zoo.visitor_count, total_revenue: zoo.revenue) }

      it 'visitors・income が前日の累計との差分(実行後の園の値)になること' do
        expect(operating.visitors).to eq(zoo.visitor_count)
        expect(operating.income).to eq(zoo.revenue)
      end
    end

    context '飼育員が100分働いているとき' do
      before { keeper.clock_in(100) }

      it '1日の終わりに worked_minutes を0にリセットすること' do
        operating

        expect(keeper.worked_minutes).to eq(0)
      end
    end

    context '体力1で空腹度100の個体がいるとき' do
      let(:dying) { build(:animal, max_health: 1).get_hungrier(100) }
      let(:occupants) { [dying] }

      it 'casualties にその個体を入れ、deaths=1 にすること' do
        expect(operating.casualties).to eq([dying])
        expect(operating.deaths).to eq(1)
      end
    end
  end

  describe '#enclosures / #on_exhibit / #keepers' do
    it '[丘]・[レオ]・[飼育員] を返すこと' do
      expect(zoo_day.enclosures).to eq([hill])
      expect(zoo_day.on_exhibit).to eq([lion])
      expect(zoo_day.keepers).to eq([keeper])
    end
  end
end
