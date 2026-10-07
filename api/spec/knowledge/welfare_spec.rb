# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '動物福祉' do
  def savanna(temp = 28, capacity: 4)
    build(:enclosure, name: 'サバンナ', temperature: Temperature.celsius(temp), capacity:)
  end

  context '清潔・適温で仲間がいて、空腹も病気もないとき' do
    it 'ストレスが和らぐこと' do
      enclosure = savanna
      a = build(:animal, name: 'A')
      occupants = [a, build(:animal, :female, name: 'B')]

      expect(build(:welfare, animal: a, enclosure:, occupants:).daily_stress).to be < 0
    end
  end

  context '不衛生なエリアにいると' do
    it 'ストレスが増すこと' do
      enclosure = savanna
      a = build(:animal, name: 'A')
      occupants = [a, build(:animal, :female, name: 'B')]
      enclosure.soil(90)

      expect(build(:welfare, animal: a, enclosure:, occupants:).daily_stress).to be > 0
    end
  end

  context '群れ性なのに仲間がいないと' do
    it '孤独でストレスが増すこと' do
      enclosure = savanna
      lone = build(:animal)
      occupants = [lone]

      expect(build(:welfare, animal: lone, enclosure:, occupants:).daily_stress).to be > 0
    end
  end

  context '単独性の種が一頭で暮らすとき' do
    it '孤独にはならず、良好な環境ならストレスが和らぐこと' do
      den = build(:enclosure, name: '極地', celsius: 0, capacity: 3)
      bear = build(:animal, species: SpeciesCatalog.polar_bear)
      occupants = [bear]

      expect(build(:welfare, animal: bear, enclosure: den, occupants:).daily_stress).to be < 0
    end
  end

  context '過密なエリアにいると' do
    it 'ストレスが増すこと' do
      den = build(:enclosure, name: '狭い獣舎', celsius: 0, capacity: 1)
      bear = build(:animal, species: SpeciesCatalog.polar_bear)
      occupants = [bear]

      expect(build(:welfare, animal: bear, enclosure: den, occupants:).daily_stress).to be > 0
    end
  end

  context '適温域の縁で快適でないと' do
    it 'ストレスが増すこと' do
      enclosure = savanna(12)
      a = build(:animal, name: 'A')
      occupants = [a, build(:animal, :female, name: 'B')]

      expect(build(:welfare, animal: a, enclosure:, occupants:).daily_stress).to be > 0
    end
  end

  context '空腹なとき' do
    it 'ストレスが増すこと' do
      enclosure = savanna
      a = build(:animal, name: 'A')
      a.get_hungrier(80)
      occupants = [a, build(:animal, :female, name: 'B')]

      expect(build(:welfare, animal: a, enclosure:, occupants:).daily_stress).to be > 0
    end
  end

  context '病気のとき' do
    it 'ストレスが増すこと' do
      enclosure = savanna
      a = build(:animal, name: 'A')
      a.fall_ill(IllnessCatalog.cold)
      occupants = [a, build(:animal, :female, name: 'B')]

      expect(build(:welfare, animal: a, enclosure:, occupants:).daily_stress).to be > 0
    end
  end
end
