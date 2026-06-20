# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Breeding do
      let(:lion) { SpeciesCatalog.lion }
      let(:sire) { build_adult(lion, name: 'レオ', sex: Animal::Sex.male) }
      let(:dam)  { build_adult(lion, name: 'ナラ', sex: Animal::Sex.female) }

      describe '.mean_kinship' do
        it '個体が1頭以下なら0であること' do
          a = build_adult(lion, name: 'A', sex: Animal::Sex.male)
          expect(described_class.mean_kinship([a], [a])).to eq(0.0)
          expect(described_class.mean_kinship([], [])).to eq(0.0)
        end
      end

      describe '#conceive' do
        it '受胎させると breeding が返り dam が妊娠状態になること' do
          result = described_class.new(sire:, dam:, day: 0).conceive
          expect(result).to be_a(described_class)
          expect(dam).to be_expecting
        end

        it 'オスとメスを取り違えると BreedingNotAllowed になること' do
          expect do
            described_class.new(sire: dam, dam: sire, day: 0).conceive
          end.to raise_error(Errors::BreedingNotAllowed)
        end

        it '異種では BreedingNotAllowed になること' do
          zebra_female = build_adult(SpeciesCatalog.grevys_zebra, sex: Animal::Sex.female)
          expect do
            described_class.new(sire:, dam: zebra_female, day: 0).conceive
          end.to raise_error(Errors::BreedingNotAllowed)
        end

        it '周年繁殖種(ライオン)はどの季節でも受胎できること' do
          expect do
            described_class.new(sire:, dam:, day: 0, season: Season.summer).conceive
          end.not_to raise_error
        end

        it '季節繁殖種(ニホンザル)は繁殖季節でない季節には受胎できないこと' do
          macaque = SpeciesCatalog.japanese_macaque
          m_sire = build_adult(macaque, name: 'M♂', sex: Animal::Sex.male)
          m_dam  = build_adult(macaque, name: 'M♀', sex: Animal::Sex.female)
          expect do
            described_class.new(sire: m_sire, dam: m_dam, day: 0, season: Season.summer).conceive
          end.to raise_error(Errors::BreedingNotAllowed)
        end
      end

      describe '近親回避(Breeding#related?)' do
        let(:lion) { SpeciesCatalog.lion }

        it '親子は related? が真であること' do
          sire = build_adult(lion, name: '父', sex: Animal::Sex.male)
          dam  = build_adult(lion, name: '母', sex: Animal::Sex.female)
          dam.conceive
          dam.gestate(lion.gestation_period_days)
          birth = Birth.new(sire: sire, dam: dam, name: '娘').deliver
          daughter = birth.offspring

          expect(Breeding.new(sire:, dam: daughter, births: [birth]).related?).to be(true)
        end

        it 'きょうだいは related? が真であること' do
          sire = build_adult(lion, name: '父', sex: Animal::Sex.male)
          dam  = build_adult(lion, name: '母', sex: Animal::Sex.female)

          dam.conceive
          dam.gestate(lion.gestation_period_days)
          brother_birth = Birth.new(sire: sire, dam: dam, name: '兄').deliver
          brother = brother_birth.offspring
          dam.conceive
          dam.gestate(lion.gestation_period_days)
          sister_birth = Birth.new(sire: sire, dam: dam, name: '妹').deliver
          sister = sister_birth.offspring

          expect(Breeding.new(sire: brother, dam: sister, births: [brother_birth, sister_birth]).related?).to be(true)
        end
      end
    end

    RSpec.describe Animal do
      let(:lion) { SpeciesCatalog.lion }
      let(:sire) { build_adult(lion, name: 'レオ', sex: Animal::Sex.male) }
      let(:dam)  { build_adult(lion, name: 'ナラ', sex: Animal::Sex.female) }

      describe '#conceive' do
        it 'オスは妊娠できないこと' do
          expect { sire.conceive }.to raise_error(Errors::BreedingNotAllowed)
        end

        it '妊娠中はさらに受胎できないこと' do
          dam.conceive
          expect { dam.conceive }.to raise_error(Errors::BreedingNotAllowed)
        end
      end

      describe '出産までのライフサイクル' do
        before { dam.conceive }

        it '妊娠期間を満たすと出産でき、子は両親を親に持つこと' do
          expect(dam).not_to be_ready_to_deliver
          dam.gestate(lion.gestation_period_days)
          expect(dam).to be_ready_to_deliver

          cub = Birth.new(sire: sire, dam: dam, name: 'シンバ').deliver.offspring
          expect(cub.species).to eq(lion)
          expect(cub.age_in_days).to eq(0)
          expect(cub.parent_ids).to contain_exactly(sire.id, dam.id)
          expect(cub.life_stage).to be_baby
        end

        it '期間を満たす前は出産できないこと' do
          dam.gestate(10)
          expect { Birth.new(sire: sire, dam: dam, name: '早産').deliver }
            .to raise_error(Errors::BreedingNotAllowed)
        end

        it '出産で Birth イベントが記録されること' do
          dam.gestate(lion.gestation_period_days)
          Birth.new(sire: sire, dam: dam, name: 'シンバ').deliver
          events = dam.pull_events
          expect(events.size).to eq(1)
          expect(events.last).to be_a(Events::Birth)
        end

        it 'name を省略すると種名ベースの仮名が付くこと' do
          dam.gestate(lion.gestation_period_days)
          cub = Birth.new(sire: sire, dam: dam).deliver.offspring
          expect(cub.name).to eq("#{lion.name_ja}の赤ちゃん")
        end
      end

      describe '近親交配係数が出産時の体力に反映されること' do
        it 'inbreeding=0.25 で受胎すると最大体力が約75%(50→38)に下がること' do
          dam.conceive(inbreeding: 0.25)
          dam.gestate(lion.gestation_period_days)
          cub = Birth.new(sire: sire, dam: dam, name: '近交子').deliver.offspring
          expect(cub.max_health).to eq(38)
        end

        it 'inbreeding=1.0 でも最大体力は最低1に保たれること' do
          dam.conceive(inbreeding: 1.0)
          dam.gestate(lion.gestation_period_days)
          cub = Birth.new(sire: sire, dam: dam, name: '極端').deliver.offspring
          expect(cub.max_health).to eq(1)
        end
      end

      describe '#gestate と流産' do
        it '妊娠していなければ流産は起こらないこと' do
          dam.get_hungrier(100)
          dam.gestate(10)
          expect(dam).not_to be_miscarried
        end

        it '母体が飢餓だと gestate で流産し妊娠が解けること' do
          dam.conceive
          dam.get_hungrier(100)
          dam.gestate(1)
          expect(dam).to be_miscarried
          expect(dam).not_to be_expecting
        end

        it '母体が過度のストレス(90)だと流産すること' do
          dam.conceive
          dam.add_stress(Animal::Stress::SEVERE_THRESHOLD)
          dam.gestate(1)
          expect(dam).to be_miscarried
        end

        it 'ストレスが過度の一歩手前(89)では流産しないこと' do
          dam.conceive
          dam.add_stress(Animal::Stress::SEVERE_THRESHOLD - 1)
          dam.gestate(1)
          expect(dam).not_to be_miscarried
          expect(dam).to be_expecting
        end

        it '流産後に再び交配すると流産フラグが解除されること' do
          dam.conceive
          dam.get_hungrier(100)
          dam.gestate(1)
          dam.satisfy_hunger(100)
          dam.conceive
          expect(dam).not_to be_miscarried
          expect(dam).to be_expecting
        end
      end

      describe '#name_animal' do
        it '名前が更新され AnimalNamed イベントが記録されること' do
          animal = build_adult(lion, name: 'ライオンの赤ちゃん', sex: Animal::Sex.female)
          animal.name_animal(name: 'ナラ')
          expect(animal.name).to eq('ナラ')
          events = animal.pull_events
          expect(events.last).to be_a(Events::AnimalNamed)
          expect(events.last.name).to eq('ナラ')
        end
      end
    end
  end
end
