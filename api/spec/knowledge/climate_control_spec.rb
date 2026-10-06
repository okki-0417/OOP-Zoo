# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '空調と屋内施設' do
  catalog = Zoo::Domain::SpeciesCatalog
  season  = Zoo::Domain::Season
  shared  = Zoo::Domain::Shared

  def enclosure(climate_controlled:)
    Zoo::Domain::Enclosure.new(
      name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(20),
      capacity: 4, climate_controlled: climate_controlled
    )
  end

  def pride(climate_controlled:)
    lion = Zoo::Domain::SpeciesCatalog.lion
    enc = enclosure(climate_controlled: climate_controlled)
    occupants = [
      build_adult(lion, name: 'A'),
      build_adult(lion, name: 'B', sex: Zoo::Domain::Animal::Sex.female)
    ]
    [enc, occupants]
  end

  describe '気候の緩和' do
    it '空調付きエリアは、季節による実効気温の変動を抑えること' do
      expect(enclosure(climate_controlled: true).effective_temperature(season.winter))
        .to eq(shared::Temperature.celsius(20))
      expect(enclosure(climate_controlled: false).effective_temperature(season.winter).celsius)
        .to be < 20
    end

    it '空調により、本来その季節に合わない種でも快適に保たれること' do
      lion = build_adult(catalog.lion, name: '主')
      controlled = enclosure(climate_controlled: true)
      uncontrolled = enclosure(climate_controlled: false)

      suitability = Zoo::Domain::ThermalSuitability
      expect(suitability.new(lion, controlled.effective_temperature(season.winter)).comfortable?).to be(true)
      expect(suitability.new(lion, uncontrolled.effective_temperature(season.winter)).comfortable?).to be(false)
    end

    it '空調が無いと厳しい季節に福祉が下がるが、空調があれば保たれること' do
      uncontrolled, uncontrolled_occupants = pride(climate_controlled: false)
      controlled, controlled_occupants = pride(climate_controlled: true)

      expect(welfare_of(uncontrolled_occupants.first, uncontrolled, uncontrolled_occupants,
                        season: season.winter).daily_stress).to be > 0
      expect(welfare_of(controlled_occupants.first, controlled, controlled_occupants,
                        season: season.winter).daily_stress).to be < 0
    end
  end

  describe '費用' do
    it '空調設備の設置には建設費の上乗せがかかること' do
      expect(Zoo::Domain::Enclosure.construction_cost(capacity: 4, climate_controlled: true))
        .to be > Zoo::Domain::Enclosure.construction_cost(capacity: 4, climate_controlled: false)
    end
  end
end
