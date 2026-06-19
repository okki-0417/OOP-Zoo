# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Breeding do
      let(:lion) { SpeciesCatalog.lion }
      let(:sire) { build_adult(lion, name: 'レオ', sex: Animal::Sex.male) }
      let(:dam)  { build_adult(lion, name: 'ナラ', sex: Animal::Sex.female) }
      let(:animal_lookup) { ->(_id) { nil } }

      describe '.mate' do
        it '雌雄の成体を交配させると子が返り、両親を親に持つこと' do
          child = described_class.mate(sire: sire, dam: dam, name: 'シンバ',
                                       sex: Animal::Sex.male, animal_lookup: animal_lookup, day: 0)
          expect(child.parent_ids).to contain_exactly(sire.id, dam.id)
        end

        it 'オスとメスを取り違えると BreedingNotAllowed になること' do
          expect do
            described_class.mate(sire: dam, dam: sire, name: '?',
                                 sex: Animal::Sex.male, animal_lookup: animal_lookup, day: 0)
          end.to raise_error(Errors::BreedingNotAllowed)
        end

        it '異種では BreedingNotAllowed になること' do
          zebra_female = build_adult(SpeciesCatalog.grevys_zebra, sex: Animal::Sex.female)
          expect do
            described_class.mate(sire: sire, dam: zebra_female, name: '?',
                                 sex: Animal::Sex.male, animal_lookup: animal_lookup, day: 0)
          end.to raise_error(Errors::BreedingNotAllowed)
        end

        it '周年繁殖種(ライオン)はどの季節でも交配できること' do
          expect do
            described_class.mate(sire: sire, dam: dam, name: '子', sex: Animal::Sex.male,
                                 season: Season.summer, animal_lookup: animal_lookup, day: 0)
          end.not_to raise_error
        end

        it '季節繁殖種(ニホンザル)は繁殖季節でない季節には交配できないこと' do
          macaque = SpeciesCatalog.japanese_macaque
          m_sire = build_adult(macaque, name: 'M♂', sex: Animal::Sex.male)
          m_dam  = build_adult(macaque, name: 'M♀', sex: Animal::Sex.female)
          expect do
            described_class.mate(sire: m_sire, dam: m_dam, name: '仔', sex: Animal::Sex.male,
                                 season: Season.summer, animal_lookup: animal_lookup, day: 0)
          end.to raise_error(Errors::BreedingNotAllowed)
        end
      end
    end

    RSpec.describe Animal do
      let(:lion) { SpeciesCatalog.lion }
      let(:sire) { build_adult(lion, name: 'レオ', sex: Animal::Sex.male) }
      let(:dam)  { build_adult(lion, name: 'ナラ', sex: Animal::Sex.female) }

      describe '#conceive' do
        it 'オスは妊娠できないこと' do
          expect { sire.conceive(sire_id: dam.id) }.to raise_error(Errors::BreedingNotAllowed)
        end

        it '妊娠中はさらに受胎できないこと' do
          dam.conceive(sire_id: sire.id)
          expect { dam.conceive(sire_id: sire.id) }.to raise_error(Errors::BreedingNotAllowed)
        end
      end

      describe '出産までのライフサイクル' do
        before { dam.conceive(sire_id: sire.id) }

        it '妊娠期間を満たすと出産でき、子は両親を親に持つこと' do
          expect(dam).not_to be_ready_to_deliver
          dam.gestate(lion.gestation_period_days)
          expect(dam).to be_ready_to_deliver

          cub = dam.deliver(name: 'シンバ', sex: Animal::Sex.male)
          expect(cub.species).to eq(lion)
          expect(cub.age_in_days).to eq(Animal::AgeInDays.zero)
          expect(cub.parent_ids).to contain_exactly(sire.id, dam.id)
          expect(cub.life_stage).to be_baby
        end

        it '期間を満たす前は出産できないこと' do
          dam.gestate(10)
          expect { dam.deliver(name: '早産', sex: Animal::Sex.female) }
            .to raise_error(Errors::BreedingNotAllowed)
        end

        it '出産で Birth イベントが記録されること' do
          dam.gestate(lion.gestation_period_days)
          dam.deliver(name: 'シンバ', sex: Animal::Sex.male)
          events = dam.pull_events
          expect(events.size).to eq(1)
          expect(events.first).to be_a(Events::Birth)
        end

        it 'inbreeding=0.25 を渡すと最大体力が約75%(50→38)に下がること' do
          dam.gestate(lion.gestation_period_days)
          cub = dam.deliver(name: '近交子', sex: Animal::Sex.female, inbreeding: 0.25)
          expect(cub.health.max).to eq(38)
        end

        it 'inbreeding=1.0 でも最大体力は最低1に保たれること' do
          dam.gestate(lion.gestation_period_days)
          cub = dam.deliver(name: '極端', sex: Animal::Sex.female, inbreeding: 1.0)
          expect(cub.health.max).to eq(1)
        end
      end

      describe '#gestate と流産' do
        it '妊娠していなければ流産は起こらないこと' do
          dam.get_hungrier(100)
          dam.gestate(10)
          expect(dam).not_to be_miscarried
        end

        it '母体が飢餓だと gestate で流産し妊娠が解けること' do
          dam.conceive(sire_id: sire.id)
          dam.get_hungrier(100)
          dam.gestate(1)
          expect(dam).to be_miscarried
          expect(dam).not_to be_expecting
        end

        it '母体が過度のストレス(90)だと流産すること' do
          dam.conceive(sire_id: sire.id)
          dam.add_stress(Animal::Stress::SEVERE_THRESHOLD)
          dam.gestate(1)
          expect(dam).to be_miscarried
        end

        it 'ストレスが過度の一歩手前(89)では流産しないこと' do
          dam.conceive(sire_id: sire.id)
          dam.add_stress(Animal::Stress::SEVERE_THRESHOLD - 1)
          dam.gestate(1)
          expect(dam).not_to be_miscarried
          expect(dam).to be_expecting
        end

        it '流産後に再び交配すると流産フラグが解除されること' do
          dam.conceive(sire_id: sire.id)
          dam.get_hungrier(100)
          dam.gestate(1)
          dam.satisfy_hunger(100)
          dam.conceive(sire_id: sire.id)
          expect(dam).not_to be_miscarried
          expect(dam).to be_expecting
        end
      end
    end

    RSpec.describe '近親回避(Animal#related_to? / can_mate_with?)' do
      let(:lion) { SpeciesCatalog.lion }

      it '親子は related_to? が真・can_mate_with? が偽であること' do
        sire = build_adult(lion, name: '父', sex: Animal::Sex.male)
        dam  = build_adult(lion, name: '母', sex: Animal::Sex.female)
        dam.conceive(sire_id: sire.id)
        dam.gestate(lion.gestation_period_days)
        daughter = dam.deliver(name: '娘', sex: Animal::Sex.female)

        daughter.grow_older((lion.maturity_age_years * 365) + 1)
        daughter.satisfy_hunger(100)

        expect(sire.related_to?(daughter)).to be(true)
        expect(sire.can_mate_with?(daughter)).to be(false)
      end

      it 'きょうだいは related_to? が真であること' do
        sire = build_adult(lion, name: '父', sex: Animal::Sex.male)
        dam  = build_adult(lion, name: '母', sex: Animal::Sex.female)

        dam.conceive(sire_id: sire.id)
        dam.gestate(lion.gestation_period_days)
        brother = dam.deliver(name: '兄', sex: Animal::Sex.male)
        dam.conceive(sire_id: sire.id)
        dam.gestate(lion.gestation_period_days)
        sister = dam.deliver(name: '妹', sex: Animal::Sex.female)

        expect(brother.sibling_of?(sister)).to be(true)
        expect(brother.related_to?(sister)).to be(true)
      end
    end
  end
end
