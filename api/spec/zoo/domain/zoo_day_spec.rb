# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe ZooDay do
      let(:zoo) { Zoo.new(name: '園', admission_fee: Shared::Money.yen(2_000), funds: Shared::Money.yen(100_000)) }
      let(:hill) { Enclosure.new(name: '丘', temperature: Shared::Temperature.celsius(28), capacity: 4) }
      let(:lion) { build_adult(SpeciesCatalog.lion, name: 'レオ') }
      let(:keeper) { build_keeper }

      def zoo_day(occupants: [lion], yesterday: nil)
        described_class.new(
          zoo:, occupancies: [build_occupancy(hill, occupants)], keepers: [keeper], veterinarians: [],
          yesterday:, random: Random.new(0)
        )
      end

      describe '#run' do
        it '1日進めると zoo.day が1になり、その日付の Operating を返すこと' do
          operating = zoo_day.run
          expect(zoo.day).to eq(1)
          expect(operating).to be_a(Operating).and have_attributes(day: 1)
        end

        it '費用は人件費・施設維持費・飼料費の合計で、expenses に内訳が並ぶこと' do
          operating = zoo_day.run
          expect(operating.expenses.map { |expense| expense.category.value }).to contain_exactly(:payroll, :upkeep, :feed)
          expect(operating.cost).to eq(Shared::Money.yen(operating.expenses.sum { |expense| expense.amount.yen }))
        end

        it '来園者と収入は前日の累計との差分になること' do
          yesterday = Operating.new(total_visitors: zoo.visitor_count, total_revenue: zoo.revenue)
          operating = zoo_day(yesterday:).run
          expect(operating.visitors).to eq(zoo.visitor_count)
          expect(operating.income).to eq(zoo.revenue)
        end

        it '飼育員の勤務は1日の終わりにリセットされること' do
          keeper.clock_in(100)
          zoo_day.run
          expect(keeper.worked_minutes).to eq(0)
        end

        it 'エリアは住人の数だけ汚れ、刺激が2減ること' do
          zoo_day.run
          expect(hill.cleanliness_level).to eq(99)
          expect(hill.enrichment.level).to eq(98)
        end

        it '死んだ動物は casualties と deaths に数えられること' do
          dying = build_adult(SpeciesCatalog.lion, name: '老', max_health: 1).tap { |animal| animal.get_hungrier(100) }
          operating = zoo_day(occupants: [dying]).run
          expect(operating.casualties).to eq([dying])
          expect(operating.deaths).to eq(1)
        end
      end

      it '#enclosures / #on_exhibit / #keepers で当日の対象を返すこと' do
        day = zoo_day
        expect(day.enclosures).to eq([hill])
        expect(day.on_exhibit).to eq([lion])
        expect(day.keepers).to eq([keeper])
      end
    end
  end
end
