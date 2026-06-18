# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '種内闘争と外傷' do
  catalog    = Zoo::Domain::SpeciesCatalog
  sex        = Zoo::Domain::Animal::Sex

  def pride(capacity: 6, area_sqm: nil)
    Zoo::Domain::Enclosure.new(
      name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(28),
      capacity: capacity, area_sqm: area_sqm
    )
  end

  def senior_and_junior(enclosure)
    lion = Zoo::Domain::SpeciesCatalog.lion
    senior = build_animal(lion, name: '長老', sex: Zoo::Domain::Animal::Sex.male, age_in_days: 4000)
    junior = build_adult(lion, name: '若オス', sex: Zoo::Domain::Animal::Sex.male)
    enclosure.admit(senior)
    enclosure.admit(junior)
    [senior, junior]
  end

  describe '闘争の激化' do
    it '余剰オスは、ストレスだけでなく負傷(体力減)を被ること' do
      enclosure = pride
      _senior, junior = senior_and_junior(enclosure)

      expect(enclosure.injury_for(junior)).to be > 0
    end

    it '過密や逃げ場(刺激)の不足は負傷を深めること' do
      spacious = pride(capacity: 6)
      _s1, j1 = senior_and_junior(spacious)

      cramped = pride(capacity: 4, area_sqm: 100)
      _s2, j2 = senior_and_junior(cramped)
      cramped.deplete_enrichment(100)

      expect(cramped.injury_for(j2)).to be > spacious.injury_for(j1)
    end
  end

  describe '致死的闘争' do
    it '深刻な闘争は致死的となり、死因が外傷として記録されること' do
      cramped = pride(capacity: 4, area_sqm: 100)
      cramped.deplete_enrichment(100)
      senior = build_animal(catalog.lion, name: '長老', sex: sex.male, age_in_days: 4000)
      junior = build_animal(catalog.lion, name: '若オス', sex: sex.male, age_in_days: 365 * 5, max_health: 10)
      cramped.admit(senior)
      cramped.admit(junior)

      dead = cramped.pass_day

      expect(dead).to include(junior)
      expect(junior.death.cause).to eq(:injury)
    end
  end

  describe '回避' do
    it 'バチェラー(独身オス)を別群に分けると、闘争を被らないこと' do
      enclosure = pride
      lone_male = build_adult(catalog.lion, name: '独身', sex: sex.male)
      enclosure.admit(lone_male)
      enclosure.admit(build_adult(catalog.lion, name: 'メス', sex: sex.female))

      expect(enclosure.injury_for(lone_male)).to eq(0)
    end
  end
end
