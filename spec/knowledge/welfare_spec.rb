# frozen_string_literal: true

require 'spec_helper'

# 飼育環境と社会的状況から、その日のストレスの増減を導く動物福祉の知識。
RSpec.describe '動物福祉' do
  welfare   = Zoo::Domain::Husbandry::Welfare
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog

  # 群れ性のライオン(適温域10〜40℃、快適帯はおよそ14.5〜35.5℃)を使う。
  def savanna(temp = 28, capacity: 4)
    Zoo::Domain::Husbandry::Enclosure.new(
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
      enclosure.soil(90) # 清潔度100→10で不衛生

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
      # ホッキョクグマは単独性。適温域-40〜15℃、快適帯はおよそ-31〜7℃。必要面積225m²。
      den = Zoo::Domain::Husbandry::Enclosure.new(
        name: '極地', temperature: shared::Temperature.celsius(0), capacity: 3
      )
      bear = build_adult(catalog.polar_bear)
      den.admit(bear)

      expect(welfare.daily_stress(bear, den)).to be < 0
    end
  end

  context '過密なエリアにいると' do
    it 'ストレスが増すこと' do
      # 単独性のホッキョクグマ(112.5m²必要)を広さ100m²(定員1)の狭い区画へ。
      den = Zoo::Domain::Husbandry::Enclosure.new(
        name: '狭い獣舎', temperature: shared::Temperature.celsius(0), capacity: 1
      )
      bear = build_adult(catalog.polar_bear)
      den.admit(bear)

      expect(welfare.daily_stress(bear, den)).to be > 0
    end
  end

  context '適温域の縁で快適でないと' do
    it 'ストレスが増すこと' do
      enclosure = savanna(12) # 適応はできるが快適帯(約14.5℃〜)の外
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
      a.get_hungrier(80) # 空腹(しきい値70以上)
      enclosure.admit(a)
      enclosure.admit(build_adult(catalog.lion, name: 'B', sex: Zoo::Domain::Animal::Sex.female))

      expect(welfare.daily_stress(a, enclosure)).to be > 0
    end
  end

  context '病気のとき' do
    it 'ストレスが増すこと' do
      enclosure = savanna
      a = build_adult(catalog.lion, name: 'A')
      a.fall_ill(Zoo::Domain::Medical::IllnessCatalog.cold)
      enclosure.admit(a)
      enclosure.admit(build_adult(catalog.lion, name: 'B', sex: Zoo::Domain::Animal::Sex.female))

      expect(welfare.daily_stress(a, enclosure)).to be > 0
    end
  end
end
