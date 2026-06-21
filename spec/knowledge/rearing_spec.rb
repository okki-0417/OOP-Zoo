# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '養育と離乳' do
  catalog = Zoo::Domain::SpeciesCatalog
  sex     = Zoo::Domain::Animal::Sex
  welfare = Zoo::Domain::Welfare

  def savanna
    Zoo::Domain::Enclosure.new(
      name: 'サバンナ', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 6
    )
  end

  def dam_and_cub(cub_age_in_days:)
    lion = Zoo::Domain::SpeciesCatalog.lion
    s = Zoo::Domain::Animal::Sex
    sire = build_adult(lion, name: '父', sex: s.male)
    dam = build_adult(lion, name: '母', sex: s.female)
    cub = Zoo::Domain::Animal.new(
      species: lion, name: '仔', sex: s.male, max_health: 100,
      age_in_days: cub_age_in_days, sire_id: sire&.id, dam_id: dam&.id
    )
    [dam, cub]
  end

  describe '離乳' do
    it '生まれたばかりの幼体はまだ離乳していないこと' do
      _dam, newborn = dam_and_cub(cub_age_in_days: 0)
      expect(newborn).not_to be_weaned
    end

    it '離乳適齢(ライオンは性成熟3年の2割=約219日)を過ぎると離乳すること' do
      _dam, grown = dam_and_cub(cub_age_in_days: 300)
      expect(grown).to be_weaned
    end
  end

  describe '早期分離' do
    context '未離乳の幼体が親と同じエリアにいるとき' do
      it '養育されて落ち着き、ストレスが和らぐこと' do
        dam, cub = dam_and_cub(cub_age_in_days: 0)
        enclosure = savanna
        occupants = [dam, cub]

        expect(welfare.daily_stress(cub, enclosure, occupants)).to be < 0
      end
    end

    context '未離乳の幼体が親から引き離されると' do
      it '仲間がいても分離ストレスを受けること' do
        _dam, cub = dam_and_cub(cub_age_in_days: 0)
        enclosure = savanna
        occupants = [
          cub,
          build_adult(catalog.lion, name: '他1'),
          build_adult(catalog.lion, name: '他2', sex: sex.female)
        ]

        expect(welfare.daily_stress(cub, enclosure, occupants)).to be > 0
      end
    end

    context '離乳済みの個体が親と離れても' do
      it '自立しているので分離ストレスは受けないこと' do
        _dam, weaned = dam_and_cub(cub_age_in_days: 300)
        enclosure = savanna
        occupants = [
          weaned,
          build_adult(catalog.lion, name: '他1'),
          build_adult(catalog.lion, name: '他2', sex: sex.female)
        ]

        expect(welfare.daily_stress(weaned, enclosure, occupants)).to be < 0
      end
    end
  end
end
