# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '動物福祉' do
  def savanna(temp = 28, capacity: 4)
    Enclosure.new(
      name: 'サバンナ', temperature: Temperature.celsius(temp), capacity: capacity
    )
  end

  context '清潔・適温で仲間がいて、空腹も病気もないとき' do
    it 'ストレスが和らぐこと' do
      enclosure = savanna
      a = build_adult(SpeciesCatalog.lion, name: 'A')
      occupants = [a, build_adult(SpeciesCatalog.lion, name: 'B', sex: Animal::Sex.female)]

      expect(welfare_of(a, enclosure, occupants).daily_stress).to be < 0
    end
  end

  context '不衛生なエリアにいると' do
    it 'ストレスが増すこと' do
      enclosure = savanna
      a = build_adult(SpeciesCatalog.lion, name: 'A')
      occupants = [a, build_adult(SpeciesCatalog.lion, name: 'B', sex: Animal::Sex.female)]
      enclosure.soil(90)

      expect(welfare_of(a, enclosure, occupants).daily_stress).to be > 0
    end
  end

  context '群れ性なのに仲間がいないと' do
    it '孤独でストレスが増すこと' do
      enclosure = savanna
      lone = build_adult(SpeciesCatalog.lion)
      occupants = [lone]

      expect(welfare_of(lone, enclosure, occupants).daily_stress).to be > 0
    end
  end

  context '単独性の種が一頭で暮らすとき' do
    it '孤独にはならず、良好な環境ならストレスが和らぐこと' do
      den = Enclosure.new(
        name: '極地', temperature: Temperature.celsius(0), capacity: 3
      )
      bear = build_adult(SpeciesCatalog.polar_bear)
      occupants = [bear]

      expect(welfare_of(bear, den, occupants).daily_stress).to be < 0
    end
  end

  context '過密なエリアにいると' do
    it 'ストレスが増すこと' do
      den = Enclosure.new(
        name: '狭い獣舎', temperature: Temperature.celsius(0), capacity: 1
      )
      bear = build_adult(SpeciesCatalog.polar_bear)
      occupants = [bear]

      expect(welfare_of(bear, den, occupants).daily_stress).to be > 0
    end
  end

  context '適温域の縁で快適でないと' do
    it 'ストレスが増すこと' do
      enclosure = savanna(12)
      a = build_adult(SpeciesCatalog.lion, name: 'A')
      occupants = [a, build_adult(SpeciesCatalog.lion, name: 'B', sex: Animal::Sex.female)]

      expect(welfare_of(a, enclosure, occupants).daily_stress).to be > 0
    end
  end

  context '空腹なとき' do
    it 'ストレスが増すこと' do
      enclosure = savanna
      a = build_adult(SpeciesCatalog.lion, name: 'A')
      a.get_hungrier(80)
      occupants = [a, build_adult(SpeciesCatalog.lion, name: 'B', sex: Animal::Sex.female)]

      expect(welfare_of(a, enclosure, occupants).daily_stress).to be > 0
    end
  end

  context '病気のとき' do
    it 'ストレスが増すこと' do
      enclosure = savanna
      a = build_adult(SpeciesCatalog.lion, name: 'A')
      a.fall_ill(IllnessCatalog.cold)
      occupants = [a, build_adult(SpeciesCatalog.lion, name: 'B', sex: Animal::Sex.female)]

      expect(welfare_of(a, enclosure, occupants).daily_stress).to be > 0
    end
  end
end
