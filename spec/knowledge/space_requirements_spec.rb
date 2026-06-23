# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '必要面積' do
  catalog  = Zoo::Domain::SpeciesCatalog
  species  = Zoo::Domain::Species
  shared   = Zoo::Domain::Shared

  describe '行動様式による違い' do
    it '広い行動圏を持つ種(大型ネコ)は、体重比だけの面積より広く要すること' do
      weight_only = catalog.lion.adult_weight.kilograms * species::SPACE_SQM_PER_KG
      expect(catalog.lion.space_requirement_sqm).to be > weight_only
      expect(catalog.lion).to be_wide_ranging
    end

    it '遊泳する種(ニシキゴイ)は水量(容積)を要するものとして割増されること' do
      expect(catalog.koi).to be_aquatic
      expect(catalog.koi.ranging_factor).to eq(species::AQUATIC_FACTOR)
    end

    it '飛翔する種(タンチョウ)は高さ(容積)を要するものとして割増されること' do
      expect(catalog.red_crowned_crane).to be_flighted
      expect(catalog.red_crowned_crane.ranging_factor).to eq(species::FLIGHTED_FACTOR)
    end
  end

  describe '群れの規模' do
    it '群れで暮らす種は、個体数に応じた面積を要すること' do
      enclosure = Zoo::Domain::Enclosure.new(
        name: 'サバンナ', temperature: shared::Temperature.celsius(28), capacity: 6
      )
      occupants = [
        build_adult(catalog.lion, name: 'A'),
        build_adult(catalog.lion, name: 'B', sex: Zoo::Domain::Animal::Sex.female)
      ]
      occupancy = Zoo::Domain::Occupancy.new(enclosure, occupants)

      expect(occupancy.required_area).to eq(2 * catalog.lion.space_requirement_sqm)
    end
  end

  describe '過密の帰結' do
    it '必要な空間を欠く(過密)と福祉が損なわれること' do
      den = Zoo::Domain::Enclosure.new(
        name: '狭い獣舎', temperature: shared::Temperature.celsius(0), capacity: 1
      )
      bear = build_adult(catalog.polar_bear)
      occupants = [bear]
      occupancy = Zoo::Domain::Occupancy.new(den, occupants)

      expect(occupancy.overcrowded?).to be(true)
      expect(welfare_of(bear, den, occupants).daily_stress).to be > 0
    end
  end
end
