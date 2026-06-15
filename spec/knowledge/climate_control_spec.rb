# frozen_string_literal: true

require 'spec_helper'

# 空調・屋内施設の知識。実際の動物園は加温・冷房・屋内放飼場で、季節や立地の気候不適合を
# 緩和する。これにより本来その地に合わない種も飼育でき、福祉を保てる。設備には費用がかかる。
RSpec.describe '空調と屋内施設' do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog
  season  = Zoo::Domain::Operations::Season
  pricing = Zoo::Domain::Operations::Pricing
  welfare = Zoo::Domain::Husbandry::Welfare
  shared  = Zoo::Domain::Shared

  def enclosure(climate_controlled:)
    Zoo::Domain::Husbandry::Enclosure.new(
      name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(20),
      capacity: 4, climate_controlled: climate_controlled
    )
  end

  def pride(climate_controlled:)
    lion = Zoo::Domain::Taxonomy::SpeciesCatalog.lion
    enc = enclosure(climate_controlled: climate_controlled)
    enc.admit(build_adult(lion, name: 'A'))
    enc.admit(build_adult(lion, name: 'B', sex: Zoo::Domain::Animal::Sex.female))
    enc
  end

  describe '気候の緩和' do
    it '空調付きエリアは、季節による実効気温の変動を抑えること' do
      expect(enclosure(climate_controlled: true).effective_temperature(season.winter))
        .to eq(shared::Temperature.celsius(20)) # 設定気温を保つ
      expect(enclosure(climate_controlled: false).effective_temperature(season.winter).celsius)
        .to be < 20 # 冬は寒く感じる
    end

    it '空調により、本来その季節に合わない種でも快適に保たれること' do
      controlled = enclosure(climate_controlled: true)
      uncontrolled = enclosure(climate_controlled: false)

      expect(catalog.lion.comfortable?(controlled.effective_temperature(season.winter))).to be(true)
      expect(catalog.lion.comfortable?(uncontrolled.effective_temperature(season.winter))).to be(false)
    end

    it '空調が無いと厳しい季節に福祉が下がるが、空調があれば保たれること' do
      uncontrolled = pride(climate_controlled: false)
      controlled = pride(climate_controlled: true)

      expect(welfare.daily_stress(uncontrolled.occupants.first, uncontrolled, season: season.winter)).to be > 0
      expect(welfare.daily_stress(controlled.occupants.first, controlled, season: season.winter)).to be < 0
    end
  end

  describe '費用' do
    it '空調設備の設置には建設費の上乗せがかかること' do
      expect(pricing.enclosure_construction_cost(capacity: 4, climate_controlled: true))
        .to be > pricing.enclosure_construction_cost(capacity: 4, climate_controlled: false)
    end
  end
end
