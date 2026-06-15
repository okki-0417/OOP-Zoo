# frozen_string_literal: true

require 'spec_helper'

# 種内闘争と外傷の知識。群れの序列争いは、ストレスに留まらず負傷・致死に至りうる。
# 逃げ場の不足や過密が闘争を激化させ、適切な分離(バチェラー群)で回避できる。
RSpec.describe '種内闘争と外傷' do
  catalog    = Zoo::Domain::Taxonomy::SpeciesCatalog
  aggression = Zoo::Domain::Husbandry::Aggression
  sex        = Zoo::Domain::Animal::Sex
  shared     = Zoo::Domain::Shared

  def pride(capacity: 6, area_sqm: nil)
    Zoo::Domain::Husbandry::Enclosure.new(
      name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(28),
      capacity: capacity, area_sqm: area_sqm
    )
  end

  def senior_and_junior(enclosure)
    lion = Zoo::Domain::Taxonomy::SpeciesCatalog.lion
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

      expect(aggression.injury_for(junior, enclosure)).to be > 0
    end

    it '過密や逃げ場(刺激)の不足は負傷を深めること' do
      spacious = pride(capacity: 6)
      _s1, j1 = senior_and_junior(spacious)

      cramped = pride(capacity: 4, area_sqm: 100) # 2頭(190m²必要)に対し狭く、過密
      _s2, j2 = senior_and_junior(cramped)
      cramped.deplete_enrichment(100) # 逃げ場が枯れる

      expect(aggression.injury_for(j2, cramped)).to be > aggression.injury_for(j1, spacious)
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

      expect(aggression.injury_for(lone_male, enclosure)).to eq(0)
    end
  end
end
