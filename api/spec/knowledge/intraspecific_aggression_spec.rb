# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '種内闘争と外傷' do
  def pride(capacity: 6, area_sqm: nil)
    Enclosure.new(
      name: 'ライオンの丘', temperature: Temperature.celsius(28),
      capacity: capacity, area_sqm: area_sqm
    )
  end

  def senior_and_junior
    lion = SpeciesCatalog.lion
    senior = build_animal(lion, name: '長老', sex: Animal::Sex.male, age_in_days: 4000)
    junior = build_adult(lion, name: '若オス', sex: Animal::Sex.male)
    [senior, junior]
  end

  def conflict(enclosure, occupants, animal)
    Companionship.new(
      enclosure: enclosure, occupancy: build_occupancy(enclosure, occupants), member: animal
    )
  end

  describe '闘争の激化' do
    it '余剰オスは、ストレスだけでなく負傷(体力減)を被ること' do
      enclosure = pride
      _senior, junior = occupants = senior_and_junior

      expect(conflict(enclosure, occupants, junior).injury).to be > 0
    end

    it '過密や逃げ場(刺激)の不足は負傷を深めること' do
      spacious = pride(capacity: 6)
      spacious_occupants = senior_and_junior
      _s1, j1 = spacious_occupants

      cramped = pride(capacity: 4, area_sqm: 100)
      cramped_occupants = senior_and_junior
      _s2, j2 = cramped_occupants
      cramped.deplete_enrichment(100)

      cramped_injury = conflict(cramped, cramped_occupants, j2).injury
      spacious_injury = conflict(spacious, spacious_occupants, j1).injury
      expect(cramped_injury).to be > spacious_injury
    end
  end

  describe '致死的闘争' do
    it '深刻な闘争は致死的となり、死因が外傷として記録されること' do
      cramped = pride(capacity: 4, area_sqm: 100)
      cramped.deplete_enrichment(100)
      senior = build_animal(SpeciesCatalog.lion, name: '長老', sex: Animal::Sex.male, age_in_days: 4000)
      junior = build_animal(SpeciesCatalog.lion, name: '若オス', sex: Animal::Sex.male, age_in_days: 365 * 5, max_health: 10)
      occupants = [senior, junior]

      occupancy = build_occupancy(cramped, occupants)
      Contagion.new(cramped, occupancy).spread
      occupants.each { |animal| AnimalDay.new(animal:, enclosure: cramped, occupancy:, season: Season.spring).run }

      expect(occupants.select(&:dead?)).to include(junior)
      expect(junior.cause_of_death).to eq(:injury)
    end
  end

  describe '回避' do
    it 'バチェラー(独身オス)を別群に分けると、闘争を被らないこと' do
      enclosure = pride
      lone_male = build_adult(SpeciesCatalog.lion, name: '独身', sex: Animal::Sex.male)
      occupants = [lone_male, build_adult(SpeciesCatalog.lion, name: 'メス', sex: Animal::Sex.female)]

      expect(conflict(enclosure, occupants, lone_male).injury).to eq(0)
    end
  end
end
