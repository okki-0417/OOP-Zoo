# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '動物福祉' do
  welfare   = Zoo::Domain::Welfare
  shared    = Zoo::Domain::Shared
  catalog = Zoo::Domain::SpeciesCatalog

  def savanna(temp = 28, capacity: 4)
    Zoo::Domain::Enclosure.new(
      name: 'サバンナ', temperature: Zoo::Domain::Shared::Temperature.celsius(temp), capacity: capacity
    )
  end

  context '清潔・適温で仲間がいて、空腹も病気もないとき' do
    it 'ストレスが和らぐこと' do
      enclosure = savanna
      a = build_adult(catalog.lion, name: 'A')
      enclosure.admit(a)
      enclosure.admit(build_adult(catalog.lion, name: 'B', sex: Zoo::Domain::Animal::Sex.female))

      expect(welfare.daily_stress(a, enclosure)).to be < 0
    end
  end

  context '不衛生なエリアにいると' do
    it 'ストレスが増すこと' do
      enclosure = savanna
      a = build_adult(catalog.lion, name: 'A')
      enclosure.admit(a)
      enclosure.admit(build_adult(catalog.lion, name: 'B', sex: Zoo::Domain::Animal::Sex.female))
      enclosure.soil(90)

      expect(welfare.daily_stress(a, enclosure)).to be > 0
    end
  end

  context '群れ性なのに仲間がいないと' do
    it '孤独でストレスが増すこと' do
      enclosure = savanna
      lone = build_adult(catalog.lion)
      enclosure.admit(lone)

      expect(welfare.daily_stress(lone, enclosure)).to be > 0
    end
  end

  context '単独性の種が一頭で暮らすとき' do
    it '孤独にはならず、良好な環境ならストレスが和らぐこと' do
      den = Zoo::Domain::Enclosure.new(
        name: '極地', temperature: shared::Temperature.celsius(0), capacity: 3
      )
      bear = build_adult(catalog.polar_bear)
      den.admit(bear)

      expect(welfare.daily_stress(bear, den)).to be < 0
    end
  end

  context '過密なエリアにいると' do
    it 'ストレスが増すこと' do
      den = Zoo::Domain::Enclosure.new(
        name: '狭い獣舎', temperature: shared::Temperature.celsius(0), capacity: 1
      )
      bear = build_adult(catalog.polar_bear)
      den.admit(bear)

      expect(welfare.daily_stress(bear, den)).to be > 0
    end
  end

  context '適温域の縁で快適でないと' do
    it 'ストレスが増すこと' do
      enclosure = savanna(12)
      a = build_adult(catalog.lion, name: 'A')
      enclosure.admit(a)
      enclosure.admit(build_adult(catalog.lion, name: 'B', sex: Zoo::Domain::Animal::Sex.female))

      expect(welfare.daily_stress(a, enclosure)).to be > 0
    end
  end

  context '空腹なとき' do
    it 'ストレスが増すこと' do
      enclosure = savanna
      a = build_adult(catalog.lion, name: 'A')
      a.get_hungrier(80)
      enclosure.admit(a)
      enclosure.admit(build_adult(catalog.lion, name: 'B', sex: Zoo::Domain::Animal::Sex.female))

      expect(welfare.daily_stress(a, enclosure)).to be > 0
    end
  end

  context '病気のとき' do
    it 'ストレスが増すこと' do
      enclosure = savanna
      a = build_adult(catalog.lion, name: 'A')
      a.fall_ill(Zoo::Domain::IllnessCatalog.cold)
      enclosure.admit(a)
      enclosure.admit(build_adult(catalog.lion, name: 'B', sex: Zoo::Domain::Animal::Sex.female))

      expect(welfare.daily_stress(a, enclosure)).to be > 0
    end
  end
end
