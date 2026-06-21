# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '季節と気候' do
  shared = Zoo::Domain::Shared
  season    = Zoo::Domain::Season
  welfare   = Zoo::Domain::Welfare

  def pride(temp)
    enclosure = Zoo::Domain::Enclosure.new(
      name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(temp), capacity: 4
    )
    occupants = [
      build_adult(Zoo::Domain::SpeciesCatalog.lion, name: 'A'),
      build_adult(Zoo::Domain::SpeciesCatalog.lion, name: 'B', sex: Zoo::Domain::Animal::Sex.female)
    ]
    [enclosure, occupants]
  end

  describe '季節の巡り' do
    it '経過日数に応じて春→夏→秋→冬と巡り、1年で一周すること' do
      expect(season.on_day(0).label).to eq('春')
      expect(season.on_day(100).label).to eq('夏')
      expect(season.on_day(200).label).to eq('秋')
      expect(season.on_day(300).label).to eq('冬')
      expect(season.on_day(365).label).to eq('春')
    end
  end

  describe '実効気温' do
    it '夏は区画の気温より暖かく感じること' do
      base = shared::Temperature.celsius(20)
      expect(season.summer.felt_temperature(base).celsius).to be > 20
    end

    it '冬は区画の気温より寒く感じること' do
      base = shared::Temperature.celsius(20)
      expect(season.winter.felt_temperature(base).celsius).to be < 20
    end
  end

  describe '季節と福祉' do
    it '冬は暖地性の動物が同じ区画でも快適でなくなり、ストレスが増えること' do
      enclosure, occupants = pride(20)
      occupant = occupants.first

      expect(welfare.daily_stress(occupant, enclosure, occupants, season: season.winter)).to be > 0
    end

    it '夏など快適な季節では、良好な飼育ならストレスが和らぐこと' do
      enclosure, occupants = pride(20)
      occupant = occupants.first

      expect(welfare.daily_stress(occupant, enclosure, occupants, season: season.summer)).to be < 0
    end
  end
end
