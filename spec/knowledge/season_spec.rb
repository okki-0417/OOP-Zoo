# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '季節と気候' do
  shared    = Zoo::Domain::Shared
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog
  calendar  = Zoo::Domain::Operations::Calendar
  season    = Zoo::Domain::Operations::Season
  welfare   = Zoo::Domain::Husbandry::Welfare

  def pride(temp)
    enclosure = Zoo::Domain::Husbandry::Enclosure.new(
      name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(temp), capacity: 4
    )
    enclosure.admit(build_adult(Zoo::Domain::Taxonomy::SpeciesCatalog.lion, name: 'A'))
    enclosure.admit(build_adult(Zoo::Domain::Taxonomy::SpeciesCatalog.lion, name: 'B',
                                sex: Zoo::Domain::Animal::Sex.female))
    enclosure
  end

  describe '季節の巡り' do
    it '経過日数に応じて春→夏→秋→冬と巡り、1年で一周すること' do
      expect(calendar.season_for(0).label).to eq('春')
      expect(calendar.season_for(100).label).to eq('夏')
      expect(calendar.season_for(200).label).to eq('秋')
      expect(calendar.season_for(300).label).to eq('冬')
      expect(calendar.season_for(365).label).to eq('春')
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

      enclosure = pride(20)
      occupant = enclosure.occupants.first

      expect(welfare.daily_stress(occupant, enclosure, season: season.winter)).to be > 0
    end

    it '夏など快適な季節では、良好な飼育ならストレスが和らぐこと' do
      enclosure = pride(20)
      occupant = enclosure.occupants.first

      expect(welfare.daily_stress(occupant, enclosure, season: season.summer)).to be < 0
    end
  end
end
