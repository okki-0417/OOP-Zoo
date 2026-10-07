# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '季節と気候' do
  def pride(temp)
    enclosure = build(:enclosure, name: 'ライオンの丘', temperature: Temperature.celsius(temp))
    occupants = [
      build(:animal, name: 'A'),
      build(:animal, :female, name: 'B')
    ]
    [enclosure, occupants]
  end

  describe '季節の巡り' do
    it '経過日数に応じて春→夏→秋→冬と巡り、1年で一周すること' do
      expect(Season.on_day(0).label).to eq('春')
      expect(Season.on_day(100).label).to eq('夏')
      expect(Season.on_day(200).label).to eq('秋')
      expect(Season.on_day(300).label).to eq('冬')
      expect(Season.on_day(365).label).to eq('春')
    end
  end

  describe '実効気温' do
    it '夏は区画の気温より暖かく感じること' do
      base = Temperature.celsius(20)
      expect(Season.summer.felt_temperature(base).celsius).to be > 20
    end

    it '冬は区画の気温より寒く感じること' do
      base = Temperature.celsius(20)
      expect(Season.winter.felt_temperature(base).celsius).to be < 20
    end
  end

  describe '季節と福祉' do
    it '冬は暖地性の動物が同じ区画でも快適でなくなり、ストレスが増えること' do
      enclosure, occupants = pride(20)
      occupant = occupants.first

      expect(build(:welfare, animal: occupant, enclosure:, occupants:, season: Season.winter).daily_stress).to be > 0
    end

    it '夏など快適な季節では、良好な飼育ならストレスが和らぐこと' do
      enclosure, occupants = pride(20)
      occupant = occupants.first

      expect(build(:welfare, animal: occupant, enclosure:, occupants:, season: Season.summer).daily_stress).to be < 0
    end
  end
end
