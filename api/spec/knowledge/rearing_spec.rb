# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '養育と離乳' do
  def savanna
    build(:enclosure, name: 'サバンナ', capacity: 6)
  end

  def dam_and_cub(cub_age_in_days:)
    lion = SpeciesCatalog.lion
    s = Animal::Sex
    sire = build(:animal, species: lion, name: '父', sex: s.male)
    dam = build(:animal, species: lion, name: '母', sex: s.female)
    cub = build(:animal, species: lion, name: '仔', sex: s.male, age_in_days: cub_age_in_days, sire:, dam:)
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

        expect(build(:welfare, animal: cub, enclosure:, occupants:).daily_stress).to be < 0
      end
    end

    context '未離乳の幼体が親から引き離されると' do
      it '仲間がいても分離ストレスを受けること' do
        _dam, cub = dam_and_cub(cub_age_in_days: 0)
        enclosure = savanna
        occupants = [
          cub,
          build(:animal, name: '他1'),
          build(:animal, :female, name: '他2')
        ]

        expect(build(:welfare, animal: cub, enclosure:, occupants:).daily_stress).to be > 0
      end
    end

    context '離乳済みの個体が親と離れても' do
      it '自立しているので分離ストレスは受けないこと' do
        _dam, weaned = dam_and_cub(cub_age_in_days: 300)
        enclosure = savanna
        occupants = [
          weaned,
          build(:animal, name: '他1'),
          build(:animal, :female, name: '他2')
        ]

        expect(build(:welfare, animal: weaned, enclosure:, occupants:).daily_stress).to be < 0
      end
    end
  end
end
