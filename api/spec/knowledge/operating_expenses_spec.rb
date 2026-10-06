# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '運営費の内訳' do
  catalog = Zoo::Domain::SpeciesCatalog
  expense = Zoo::Domain::Operating::Expense

  def enclosure(name, climate_controlled: false)
    Zoo::Domain::Enclosure.new(
      name:, temperature: Zoo::Domain::Shared::Temperature.celsius(25), capacity: 4, climate_controlled:
    )
  end

  def breakdown(enclosures: [], staff: [], species: [])
    Zoo::Domain::OperatingCost.new(enclosures:, staff:, species:).expenses
  end

  context '職員を雇っているとき' do
    it '人件費として、職員1人ごとに職名と名前で計上されること(飼育員 田中・獣医 佐藤)' do
      staff = [
        Zoo::Domain::Keeper.new(name: '田中', specialties: [Zoo::Domain::TaxonClass.mammal]),
        Zoo::Domain::Veterinarian.new(name: '佐藤')
      ]

      payroll = breakdown(staff:)
      expect(payroll.map(&:category)).to all(eq(expense::Category.payroll))
      expect(payroll.map(&:subject)).to eq(['飼育員 田中', '獣医 佐藤'])
    end
  end

  context 'エリアがあるとき' do
    it '施設維持費として、エリアごとに計上されること' do
      upkeep = breakdown(enclosures: [enclosure('サバンナ'), enclosure('熱帯館')])
      expect(upkeep.map(&:category)).to all(eq(expense::Category.upkeep))
      expect(upkeep.map(&:subject)).to eq(%w[サバンナ 熱帯館])
    end

    it '空調付きのエリアは、空調の稼働費ぶん施設維持費が高いこと' do
      plain = breakdown(enclosures: [enclosure('サバンナ')]).first
      controlled = breakdown(enclosures: [enclosure('熱帯館', climate_controlled: true)]).first
      expect(controlled.amount).to be > plain.amount
    end
  end

  context '動物を飼っているとき' do
    it '飼料費として、種ごとに頭数をまとめて計上されること(ライオン3頭・ゾウ1頭 → 2行)' do
      feed = breakdown(species: [catalog.lion, catalog.african_elephant, catalog.lion, catalog.lion])
      expect(feed.map(&:category)).to all(eq(expense::Category.feed))
      expect(feed.to_h { |e| [e.subject, e.quantity] }).to eq('ライオン' => 3, 'アフリカゾウ' => 1)
    end

    it '種の飼料費は、1頭あたりの飼料費×頭数となること' do
      lions = breakdown(species: Array.new(3) { catalog.lion }).first
      expect(lions.amount).to eq(catalog.lion.daily_food_cost * 3)
    end
  end

  context '内訳を合計すると' do
    it '1日の運営費の総額と一致すること' do
      cost = Zoo::Domain::OperatingCost.new(
        enclosures: [enclosure('サバンナ')], staff: [build_keeper], species: [catalog.lion, catalog.lion]
      )
      expect(cost.expenses.sum(Zoo::Domain::Shared::Money.zero, &:amount)).to eq(cost.amount)
    end
  end
end
