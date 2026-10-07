# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AnimalDay do
  def savanna(temp = 28)
    build(:enclosure, name: 'サバンナ', temperature: Temperature.celsius(temp))
  end

  def animal_day(animal, enclosure, occupants)
    described_class.new(
      animal: animal, enclosure: enclosure,
      occupancy: Occupancy.new(enclosure: enclosure, occupants: occupants), season: Season.spring
    )
  end

  describe '#run' do
    it '個体が1日ぶん歳をとること' do
      enclosure = savanna
      a = build(:animal, name: 'A')
      occupants = [a, build(:animal, :female, name: 'B')]

      expect { animal_day(a, enclosure, occupants).run }.to change { a.age_in_days }.by(1)
    end

    it '群れ性が一頭きりで孤独だと福祉が下がりストレスが増すこと' do
      enclosure = savanna
      lone = build(:animal)

      expect { animal_day(lone, enclosure, [lone]).run }.to change { lone.stress_level }.by_at_least(1)
    end

    it '序列下位のオスは闘争で負傷し体力が減ること' do
      enclosure = savanna
      senior = build(:animal, name: '長老', age_in_days: 4000)
      junior = build(:animal, name: '若')

      expect { animal_day(junior, enclosure, [senior, junior]).run }
        .to change { junior.current_health }.by_at_most(-1)
    end

    it '給餌されなかった個体は settle_nutrition により nutrition_level が 100 から 75 になること' do
      enclosure = savanna
      lion = build(:animal)

      expect { animal_day(lion, enclosure, [lion]).run }.to change { lion.nutrition_level }.from(100).to(75)
    end

    it '妊娠中のメスは gestate(1) され、gestation_days が 0 から 1 になること' do
      enclosure = savanna
      sire = build(:animal)
      dam = build(:animal, :female)
      dam.conceive

      animal_day(dam, enclosure, [sire, dam]).run
      dam.gestate(SpeciesCatalog.lion.gestation_period_days - 1)
      expect(dam).to be_ready_to_deliver
    end

    it '外傷で死亡した個体は同じ日に加齢しないこと' do
      enclosure = savanna
      senior = build(:animal, name: '長老', age_in_days: 4000)
      junior = build(:animal, name: '若', max_health: 1)

      expect { animal_day(junior, enclosure, [senior, junior]).run }.not_to(change { junior.age_in_days })
      expect(junior.cause_of_death).to eq(:injury)
    end

    it '死亡している個体は加齢もストレスも受けないこと' do
      enclosure = savanna
      dead = build(:animal)
      dead.die

      expect { animal_day(dead, enclosure, [dead]).run }.not_to(change { dead.age_in_days })
    end
  end
end
