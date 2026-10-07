# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '空調と屋内施設' do
  def enclosure(climate_controlled:)
    build(:enclosure, name: 'ライオンの丘', celsius: 20, climate_controlled:)
  end

  def pride(climate_controlled:)
    lion = SpeciesCatalog.lion
    enc = enclosure(climate_controlled: climate_controlled)
    occupants = [
      build(:animal, species: lion, name: 'A'),
      build(:animal, :female, species: lion, name: 'B')
    ]
    [enc, occupants]
  end

  describe '気候の緩和' do
    it '空調付きエリアは、季節による実効気温の変動を抑えること' do
      expect(enclosure(climate_controlled: true).effective_temperature(Season.winter))
        .to eq(Temperature.celsius(20))
      expect(enclosure(climate_controlled: false).effective_temperature(Season.winter).celsius)
        .to be < 20
    end

    it '空調により、本来その季節に合わない種でも快適に保たれること' do
      lion = build(:animal, name: '主')
      controlled = enclosure(climate_controlled: true)
      uncontrolled = enclosure(climate_controlled: false)

      suitability = ThermalSuitability
      expect(suitability.new(lion, controlled.effective_temperature(Season.winter)).comfortable?).to be(true)
      expect(suitability.new(lion, uncontrolled.effective_temperature(Season.winter)).comfortable?).to be(false)
    end

    it '空調が無いと厳しい季節に福祉が下がるが、空調があれば保たれること' do
      uncontrolled, uncontrolled_occupants = pride(climate_controlled: false)
      controlled, controlled_occupants = pride(climate_controlled: true)

      expect(build(:welfare, animal: uncontrolled_occupants.first, enclosure: uncontrolled, occupants: uncontrolled_occupants,
                             season: Season.winter).daily_stress).to be > 0
      expect(build(:welfare, animal: controlled_occupants.first, enclosure: controlled, occupants: controlled_occupants,
                             season: Season.winter).daily_stress).to be < 0
    end
  end

  describe '費用' do
    it '空調設備の設置には建設費の上乗せがかかること' do
      expect(Enclosure.construction_cost(capacity: 4, climate_controlled: true))
        .to be > Enclosure.construction_cost(capacity: 4, climate_controlled: false)
    end
  end
end
