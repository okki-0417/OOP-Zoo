# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    module Breeding
      RSpec.describe BreedingPair do
        let(:lion) { Taxonomy::SpeciesCatalog.lion }
        let(:sire) { build_adult(lion, name: 'レオ', sex: Animal::Sex.male) }
        let(:dam) { build_adult(lion, name: 'ナラ', sex: Animal::Sex.female) }

        it '雌雄の成体でペアを組めること' do
          expect { described_class.new(sire: sire, dam: dam) }.not_to raise_error
        end

        it '#to_s は 種の繁殖ペア(♂×♀) の形で表されること' do
          pair = described_class.new(sire: sire, dam: dam)
          expect(pair.to_s).to eq('ライオンの繁殖ペア(レオ×ナラ)')
        end

        it 'オスとメスを取り違えるとペアにできないこと' do
          expect { described_class.new(sire: dam, dam: sire) }
            .to raise_error(Errors::BreedingNotAllowed)
        end

        it '異種ではペアにできないこと' do
          zebra_female = build_adult(Taxonomy::SpeciesCatalog.grevys_zebra, sex: Animal::Sex.female)
          expect { described_class.new(sire: sire, dam: zebra_female) }
            .to raise_error(Errors::BreedingNotAllowed)
        end

        it '周年繁殖種(ライオン)はどの季節でも交尾できること' do
          pair = described_class.new(sire: sire, dam: dam)
          expect { pair.mate(season: Operations::Season.summer) }.not_to raise_error
        end

        it '季節繁殖種(ニホンザル)は繁殖季節でない季節には交尾できないこと' do
          macaque = Taxonomy::SpeciesCatalog.japanese_macaque
          pair = described_class.new(
            sire: build_adult(macaque, name: 'M♂', sex: Animal::Sex.male),
            dam: build_adult(macaque, name: 'M♀', sex: Animal::Sex.female)
          )
          expect { pair.mate(season: Operations::Season.summer) }.to raise_error(Errors::BreedingNotAllowed)
        end

        describe '出産までのライフサイクル' do
          let(:pair) { described_class.new(sire: sire, dam: dam) }

          it '妊娠期間を経て出産でき、子は両親を親に持つこと' do
            pair.mate
            expect(pair).not_to be_ready_to_deliver
            pair.advance(lion.gestation_period_days)
            expect(pair).to be_ready_to_deliver

            cub = pair.deliver(name: 'シンバ', sex: Animal::Sex.male)
            expect(cub.species).to eq(lion)
            expect(cub.age_in_days).to eq(Animal::AgeInDays.zero)
            expect(cub.parent_ids).to contain_exactly(sire.id, dam.id)
            expect(cub.life_stage).to be_baby
          end

          it '期間を満たす前は出産できないこと' do
            pair.mate
            pair.advance(10)
            expect { pair.deliver(name: '早産', sex: Animal::Sex.female) }
              .to raise_error(Errors::BreedingNotAllowed)
          end

          it '出産でAnimalBornイベントが記録されること' do
            pair.mate
            pair.advance(lion.gestation_period_days)
            pair.deliver(name: 'シンバ', sex: Animal::Sex.male)
            events = pair.pull_events
            expect(events.size).to eq(1)
            expect(events.first).to be_a(Events::AnimalBorn)
          end

          it 'inbreeding=0.25 を渡すと最大体力が約75%(50→38)に下がること' do
            pair.mate
            pair.advance(lion.gestation_period_days)
            cub = pair.deliver(name: '近交子', sex: Animal::Sex.female, inbreeding: 0.25)
            expect(cub.health.max).to eq(38)
          end

          it 'inbreeding=1.0 でも最大体力は最低1に保たれること' do
            pair.mate
            pair.advance(lion.gestation_period_days)
            cub = pair.deliver(name: '極端', sex: Animal::Sex.female, inbreeding: 1.0)
            expect(cub.health.max).to eq(1)
          end
        end

        describe '流産' do
          let(:pair) { described_class.new(sire: sire, dam: dam) }

          it '妊娠していなければ流産は起こらないこと' do
            dam.get_hungrier(100)
            pair.advance(10)
            expect(pair).not_to be_miscarried
          end

          it '母体が飢餓だと advance で流産し妊娠が解けること' do
            pair.mate
            dam.get_hungrier(100)
            pair.advance(1)
            expect(pair).to be_miscarried
            expect(pair).not_to be_expecting
          end

          it '母体が過度のストレス(90)だと流産すること' do
            pair.mate
            dam.add_stress(Animal::Stress::SEVERE_THRESHOLD)
            pair.advance(1)
            expect(pair).to be_miscarried
          end

          it 'ストレスが過度の一歩手前(89)では流産しないこと' do
            pair.mate
            dam.add_stress(Animal::Stress::SEVERE_THRESHOLD - 1)
            pair.advance(1)
            expect(pair).not_to be_miscarried
            expect(pair).to be_expecting
          end

          it '流産後に再び交尾すると流産フラグが解除されること' do
            pair.mate
            dam.get_hungrier(100)
            pair.advance(1)
            dam.satisfy_hunger(100)
            pair.mate
            expect(pair).not_to be_miscarried
            expect(pair).to be_expecting
          end
        end
      end

      RSpec.describe BreedingPolicy do
        let(:lion) { Taxonomy::SpeciesCatalog.lion }

        it '近親(親子)は繁殖できないこと' do
          sire = build_adult(lion, name: '父', sex: Animal::Sex.male)
          dam = build_adult(lion, name: '母', sex: Animal::Sex.female)
          pair = BreedingPair.new(sire: sire, dam: dam)
          pair.mate
          pair.advance(lion.gestation_period_days)
          daughter = pair.deliver(name: '娘', sex: Animal::Sex.female)

          daughter.grow_older(lion.maturity_age_years * 365 + 1)
          daughter.satisfy_hunger(100)

          expect(described_class.related?(sire, daughter)).to be(true)
          expect(described_class.can_mate?(sire, daughter)).to be(false)
        end

        it 'きょうだいは繁殖できないこと' do
          sire = build_adult(lion, name: '父', sex: Animal::Sex.male)
          dam = build_adult(lion, name: '母', sex: Animal::Sex.female)
          pair = BreedingPair.new(sire: sire, dam: dam)

          pair.mate
          pair.advance(lion.gestation_period_days)
          brother = pair.deliver(name: '兄', sex: Animal::Sex.male)
          pair.mate
          pair.advance(lion.gestation_period_days)
          sister = pair.deliver(name: '妹', sex: Animal::Sex.female)

          expect(brother.sibling_of?(sister)).to be(true)
          expect(described_class.related?(brother, sister)).to be(true)
        end
      end
    end
  end
end
