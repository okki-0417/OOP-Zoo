# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '入園料と需要' do
  def exhibit
    catalog = Zoo::Domain::SpeciesCatalog
    [build_adult(catalog.lion, name: 'A'), build_adult(catalog.grevys_zebra, name: 'B')]
  end

  def visitors_at(fee)
    Zoo::Domain::VisitorAttraction.expected_visitors(
      exhibit, Zoo::Domain::Zoo::Reputation.default.factor, Zoo::Domain::Shared::Money.yen(fee)
    )
  end

  def revenue_at(fee)
    fee * visitors_at(fee)
  end

  describe '需要曲線' do
    it '入園料を上げると来園者が減ること' do
      expect(visitors_at(3_000)).to be < visitors_at(1_000)
    end

    it '十分に高い料金では来園者がいなくなること' do
      expect(visitors_at(100_000)).to eq(0)
    end
  end

  describe '収益の最適点' do
    FEES = [200, 400, 800, 1_600, 3_200, 6_400, 12_800, 25_600].freeze

    it '収益を最大化する料金が、最安値ではないこと(安売りは取りこぼす)' do
      revenues = FEES.map { |fee| revenue_at(fee) }
      best_index = revenues.each_index.max_by { |i| revenues[i] }
      expect(best_index).not_to eq(0)
    end

    it '収益を最大化する料金が、最高値ではないこと(高すぎると客が来ない)' do
      revenues = FEES.map { |fee| revenue_at(fee) }
      best_index = revenues.each_index.max_by { |i| revenues[i] }
      expect(best_index).not_to eq(FEES.size - 1)
    end

    it '中庸の料金は、安すぎ・高すぎの両極より収益が大きいこと' do
      cheap  = revenue_at(FEES.first)
      mid    = revenue_at(3_200)
      pricey = revenue_at(FEES.last)
      expect(mid).to be > cheap
      expect(mid).to be > pricey
    end
  end

  describe '入場の上限(需要を超えない)' do
    it '需要を超える人数を手動で入れても、実際の入場は需要が上限になること' do
      pending('需要を上限とする入場の導入で対応予定。現状 admit_visitors は無制限に受け入れる')
      catalog = Zoo::Domain::SpeciesCatalog
      zoo = Zoo::Domain::Zoo.new(name: '園', admission_fee: Zoo::Domain::Shared::Money.yen(2_000))
      enc = zoo.add_enclosure(
        Zoo::Domain::Enclosure.new(
          name: 'サバンナ', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4
        )
      )
      zoo.house(build_adult(catalog.lion, name: 'レオ'), enc)

      demand = Zoo::Domain::VisitorAttraction.expected_visitors(
        zoo.animals, zoo.reputation_factor, zoo.admission_fee
      )
      zoo.admit_visitors(1_000_000)

      expect(zoo.visitor_count).to be <= demand
    end
  end

  describe '入園料の妥当性' do
    it '入園料には上限があり、極端な値(int64を溢れさせる額)は設定できないこと'
  end
end
