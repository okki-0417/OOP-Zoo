# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::AnimalDay do
  catalog = Zoo::Domain::SpeciesCatalog
  sex     = Zoo::Domain::Animal::Sex

  def savanna(temp = 28)
    Zoo::Domain::Enclosure.new(
      name: 'サバンナ', temperature: Zoo::Domain::Shared::Temperature.celsius(temp), capacity: 4
    )
  end

  def animal_day(animal, enclosure, occupants)
    described_class.new(
      animal: animal, enclosure: enclosure,
      occupancy: Zoo::Domain::Occupancy.new(enclosure, occupants), season: Zoo::Domain::Season.spring
    )
  end

  describe '#run' do
    it '個体が1日ぶん歳をとること' do
      enclosure = savanna
      a = build_adult(catalog.lion, name: 'A')
      occupants = [a, build_adult(catalog.lion, name: 'B', sex: sex.female)]

      expect { animal_day(a, enclosure, occupants).run }.to change { a.age_in_days }.by(1)
    end

    it '群れ性が一頭きりで孤独だと福祉が下がりストレスが増すこと' do
      enclosure = savanna
      lone = build_adult(catalog.lion)

      expect { animal_day(lone, enclosure, [lone]).run }.to change { lone.stress_level }.by_at_least(1)
    end

    it '序列下位のオスは闘争で負傷し体力が減ること' do
      enclosure = savanna
      senior = build_animal(catalog.lion, name: '長老', sex: sex.male, age_in_days: 4000)
      junior = build_adult(catalog.lion, name: '若', sex: sex.male)

      expect { animal_day(junior, enclosure, [senior, junior]).run }
        .to change { junior.current_health }.by_at_most(-1)
    end

    it '死亡している個体は加齢もストレスも受けないこと' do
      enclosure = savanna
      dead = build_adult(catalog.lion)
      dead.die

      expect { animal_day(dead, enclosure, [dead]).run }.not_to change { dead.age_in_days }
    end
  end
end
