# frozen_string_literal: true

require 'spec_helper'

# DailyOperation は「1日のサイクル」のプロセス型ドメインサービス。
# リポジトリや UnitOfWork を一切使わず、読み込み済みの集約だけで検証できる(テスト容易性)。
RSpec.describe Zoo::Domain::Operations::DailyOperation do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  operations = Zoo::Domain::Operations

  def savanna_with_zebra
    enclosure = Zoo::Domain::Husbandry::Enclosure.new(
      name: 'サバンナ', temperature: Zoo::Domain::Shared::Temperature.celsius(30), capacity: 6
    )
    zebra = build_adult(Zoo::Domain::Taxonomy::SpeciesCatalog.grevys_zebra, name: 'シマオ')
    enclosure.admit(zebra)
    [enclosure, zebra]
  end

  let(:zoo) do
    Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: shared::Money.yen(2_000), funds: shared::Money.yen(100_000))
  end
  let(:no_outbreak) { instance_double(Random, rand: 99) } # rand>=20 で疫病を起こさない

  describe '.run' do
    it 'リポジトリ無しで1日を回し、日送り・収支・評判を集約に反映すること' do
      enclosure, zebra = savanna_with_zebra
      zebra_food = husbandry::Metabolism.daily_food_cost(catalog.grevys_zebra).yen
      upkeep = operations::OperatingCost::UPKEEP_PER_ENCLOSURE

      outcome = described_class.run(
        zoo: zoo, enclosures: [enclosure], animals: [zebra], dead: [],
        staff_count: 0, random: no_outbreak
      )

      # 集客=線形需要(魅力60・評判50・料金2000) → 12人
      expect(outcome.visitors).to eq(12)
      expect(outcome.income).to eq(shared::Money.yen(24_000))     # 2000 * 12
      expect(zoo.day).to eq(1)                                     # 日送り
      expect(zoo.balance).to eq(shared::Balance.new(100_000 + 24_000 - (upkeep + zebra_food)))
      expect(zoo.reputation.score).to eq(50)                       # 12人では露出が小さく、単日では表示は据え置き(端数は累積)
      expect(outcome.afflicted).to be_nil
    end

    it '疫病の乱数だと在園個体が発病し、outcome に発病個体が入ること' do
      enclosure, zebra = savanna_with_zebra
      outbreak = instance_double(Random, rand: 0) # 発生＋先頭個体を選ぶ

      outcome = described_class.run(
        zoo: zoo, enclosures: [enclosure], animals: [zebra], dead: [],
        staff_count: 0, random: outbreak
      )

      expect(outcome.afflicted).to eq(zebra)
      expect(zebra).to be_sick
      expect(outcome.outbreak_name).to eq('シマオ')
    end

    it '死亡が多い日は評判を押し下げること' do
      enclosure, _zebra = savanna_with_zebra
      dead = [build_adult(catalog.grevys_zebra, name: '故')]

      described_class.run(
        zoo: zoo, enclosures: [enclosure], animals: enclosure.occupants, dead: dead,
        staff_count: 0, random: no_outbreak
      )

      expect(zoo.reputation.score).to be < operations::Reputation.default.score
    end
  end
end
