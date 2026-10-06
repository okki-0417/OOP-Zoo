# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '群れと社会構造' do
  catalog = Zoo::Domain::SpeciesCatalog
  sex     = Zoo::Domain::Animal::Sex

  def savanna(capacity: 4, temp: 28)
    Zoo::Domain::Enclosure.new(
      name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(temp), capacity: capacity
    )
  end

  describe '序列と余剰オス' do
    context '群れ性の種で成熟したオスが複数同居すると' do
      it '最も年長でない(序列下位の)オスは闘争でストレスを受けること' do
        enclosure = savanna
        senior = build_animal(catalog.lion, name: '長老', sex: sex.male, age_in_days: 4000)
        junior = build_adult(catalog.lion, name: '若オス', sex: sex.male)
        occupants = [senior, junior]

        expect(welfare_of(junior, enclosure, occupants).daily_stress).to be > 0
      end

      it '最も年長のオス(優位)はストレスを受けないこと' do
        enclosure = savanna
        senior = build_animal(catalog.lion, name: '長老', sex: sex.male, age_in_days: 4000)
        junior = build_adult(catalog.lion, name: '若オス', sex: sex.male)
        occupants = [senior, junior]

        expect(welfare_of(senior, enclosure, occupants).daily_stress).to be < 0
      end
    end

    context '成熟したオスが1頭だけのとき' do
      it '序列闘争は起きないこと' do
        enclosure = savanna
        male = build_adult(catalog.lion, name: 'オス', sex: sex.male)
        female = build_adult(catalog.lion, name: 'メス', sex: sex.female)
        occupants = [male, female]

        expect(welfare_of(male, enclosure, occupants).daily_stress).to be < 0
      end
    end
  end
end
