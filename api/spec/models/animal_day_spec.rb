# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AnimalDay do
  subject(:animal_day) do
    described_class.new(animal:, enclosure:, occupancy: Occupancy.new(enclosure:, occupants:), season: Season.spring)
  end

  let(:enclosure) { build(:enclosure, name: 'サバンナ') }
  let(:animal) { build(:animal) }
  let(:companion) { build(:animal, :female) }
  let(:occupants) { [animal, companion] }

  describe '#run' do
    context 'オスとメスのライオンが同居しているとき' do
      it '個体の日齢が1増えること' do
        expect { animal_day.run }.to change(animal, :age_in_days).by(1)
      end
    end

    context '群れ性のライオンが一頭きりのとき' do
      let(:occupants) { [animal] }

      it '孤独で福祉が下がり、ストレスが1以上増えること' do
        expect { animal_day.run }.to change(animal, :stress_level).by_at_least(1)
      end

      it '給餌されていないので、settle_nutrition で nutrition_level が 100 から 75 になること' do
        expect { animal_day.run }.to change(animal, :nutrition_level).from(100).to(75)
      end
    end

    context '日齢4000の長老オスと同居する若いオスのとき' do
      let(:companion) { build(:animal, name: '長老', age_in_days: 4000) }

      it '序列闘争で負傷し、体力が1以上減ること' do
        expect { animal_day.run }.to change(animal, :current_health).by_at_most(-1)
      end
    end

    context '日齢4000の長老オスと同居する体力1の若いオスのとき' do
      let(:animal) { build(:animal, max_health: 1) }
      let(:companion) { build(:animal, name: '長老', age_in_days: 4000) }

      it '外傷(:injury)で死亡し、同じ日には加齢しないこと' do
        expect { animal_day.run }.not_to change(animal, :age_in_days)
        expect(animal.cause_of_death).to eq(:injury)
      end
    end

    context '妊娠中のメスのとき' do
      let(:animal) { build(:animal, :female).conceive }
      let(:companion) { build(:animal) }

      it '1日 gestate され、残り(妊娠期間 - 1)日で出産できるようになること' do
        animal_day.run
        animal.gestate(SpeciesCatalog.lion.gestation_period_days - 1)

        expect(animal).to be_ready_to_deliver
      end
    end

    context '死亡している個体のとき' do
      let(:animal) { build(:animal).die }
      let(:occupants) { [animal] }

      it '加齢しないこと' do
        expect { animal_day.run }.not_to change(animal, :age_in_days)
      end
    end
  end
end
