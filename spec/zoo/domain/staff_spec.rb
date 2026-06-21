# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Keeper do
      let(:mammal_keeper) do
        described_class.new(name: '田中', specialties: [TaxonClass.mammal])
      end
      let(:lion) { build_adult(SpeciesCatalog.lion) }
      let(:penguin) { build_adult(SpeciesCatalog.emperor_penguin) }

      it '専門の綱の動物を担当できること' do
        expect(mammal_keeper.specialized_in?(lion.taxon_class)).to be(true)
        expect(mammal_keeper.specialized_in?(penguin.taxon_class)).to be(false)
      end

      it '専門の動物に給餌できること' do
        lion.get_hungrier(50)
        expect { mammal_keeper.feed(lion, FoodCatalog.horse_meat) }
          .to change { lion.hunger_level }.by(-35)
      end

      it '専門外の動物には給餌できないこと' do
        expect { mammal_keeper.feed(penguin, FoodCatalog.sardine) }
          .to raise_error(Errors::FeedingNotAllowed)
      end

      it 'エリアを清掃できること' do
        enclosure = Enclosure.new(
          name: 'サバンナ', temperature: Shared::Temperature.celsius(30), capacity: 5
        )
        enclosure.soil(40)
        expect { mammal_keeper.clean(enclosure) }
          .to change { enclosure.cleanliness.level }.to(100)
      end

      it '専門を持たない飼育員は作れないこと' do
        expect { described_class.new(name: '空', specialties: []) }.to raise_error(ArgumentError)
      end

      it '担当エリアを割り当てると assigned_enclosures に現れ、複製を返すこと' do
        enclosure = Enclosure.new(
          name: 'サバンナ', temperature: Shared::Temperature.celsius(30), capacity: 5
        )
        mammal_keeper.assign_to(enclosure)
        expect(mammal_keeper.assigned_enclosures).to contain_exactly(enclosure)
        mammal_keeper.assigned_enclosures.clear
        expect(mammal_keeper.assigned_enclosures).to contain_exactly(enclosure)
      end

      it '#to_s は 飼育員 名前(専門担当) の形で表されること' do
        expect(mammal_keeper.to_s).to start_with('飼育員 田中(')
        expect(mammal_keeper.to_s).to end_with('担当)')
      end
    end

    RSpec.describe Veterinarian do
      let(:vet) { described_class.new(name: '佐藤') }
      let(:animal) { build_adult(SpeciesCatalog.lion) }

      it '#to_s は 獣医 名前 の形で表されること' do
        expect(vet.to_s).to eq('獣医 佐藤')
      end

      it '健康な個体を健康と診断すること' do
        expect(vet.examine(animal)).to eq(:healthy)
      end

      it '病気の個体を診断し、治療で治せること' do
        animal.fall_ill(IllnessCatalog.pneumonia)
        expect(vet.examine(animal)).to eq(:sick)
        vet.treat(animal)
        expect(animal).not_to be_sick
      end

      it '衰弱した個体を診断し、治療で回復させること' do
        90.times { animal.cry_out }
        expect(vet.examine(animal)).to eq(:injured)
        vet.treat(animal)
        expect(animal.weak?).to be(false)
      end

      it '死亡個体は治療できないこと' do
        animal.die
        expect(vet.examine(animal)).to eq(:dead)
        expect { vet.treat(animal) }.to raise_error(Errors::DeadAnimal)
      end
    end

    RSpec.describe '病気の進行' do
      let(:animal) { build_adult(SpeciesCatalog.lion, max_health: 30) }

      it '治療しないと病気で衰弱し、やがて死亡すること' do
        animal.fall_ill(IllnessCatalog.pneumonia)
        animal.grow_older(5)
        expect(animal).to be_dead
        expect(animal.cause_of_death).to eq(:illness)
      end
    end
  end
end
