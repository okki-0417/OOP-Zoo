# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ZooDay do
  describe '.current' do
    subject(:current) { described_class.current(random: Random.new(0)) }

    let!(:hill) { create(:enclosure, name: '丘') }
    let!(:lion) { create(:animal, name: 'レオ', enclosure: hill) }
    let!(:keeper) { create(:keeper) }

    it '保存済みの園・エリア・動物・飼育員から1日を組み立てること' do
      expect(current.zoo).to eq(Zoo.current)
      expect(current.enclosures).to eq([hill])
      expect(current.on_exhibit).to eq([lion])
      expect(current.keepers).to eq([keeper])
    end

    context '前日の営業が保存済みのとき' do
      before { described_class.current(random: Random.new(0)).run }

      it '#run で day=2 の Operating を返すこと' do
        expect(current.run.day).to eq(2)
      end
    end
  end

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

    it 'Operating・園・エリア・動物・飼育員を保存すること' do
      expect(operating).to be_persisted
      expect([zoo, hill, lion, keeper]).to all(be_persisted)
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
