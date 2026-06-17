# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    module Husbandry
      RSpec.describe '同居の相性' do
        let(:lion) { Taxonomy::SpeciesCatalog.lion }
        let(:zebra) { Taxonomy::SpeciesCatalog.grevys_zebra }
        let(:giraffe) { Taxonomy::SpeciesCatalog.reticulated_giraffe }
        let(:polar_bear) { Taxonomy::SpeciesCatalog.polar_bear }
        let(:penguin) { Taxonomy::SpeciesCatalog.emperor_penguin }

        it '草食動物同士は混合展示できること' do
          expect(zebra.can_cohabit_with?(giraffe)).to be(true)
        end

        it '肉食動物は異種と同居できないこと' do
          expect(lion.can_cohabit_with?(zebra)).to be(false)
        end

        it '群れで暮らす種は同種を同居できること' do
          expect(lion.can_cohabit_with?(lion)).to be(true)
        end

        it '単独性の種は同種でも同居できないこと' do
          expect(polar_bear.can_cohabit_with?(polar_bear)).to be(false)
        end

        it '適温域が両立しない種同士は同居できないこと' do
          expect(lion.can_cohabit_with?(penguin)).to be(false)
        end
      end

      RSpec.describe Enclosure do
        let(:savanna) do
          described_class.new(name: 'アフリカサバンナ', temperature: Shared::Temperature.celsius(30), capacity: 3)
        end
        let(:zebra) { Taxonomy::SpeciesCatalog.grevys_zebra }
        let(:giraffe) { Taxonomy::SpeciesCatalog.reticulated_giraffe }
        let(:lion) { Taxonomy::SpeciesCatalog.lion }

        it '気候に適応した個体を収容できること' do
          savanna.admit(build_adult(zebra))
          expect(savanna.population).to eq(1)
        end

        it '草食動物の混合展示ができること' do
          savanna.admit(build_adult(zebra))
          savanna.admit(build_adult(giraffe))
          expect(savanna.species_present.size).to eq(2)
        end

        it '定員を超えると収容できないこと' do
          3.times { |i| savanna.admit(build_adult(zebra, name: "z#{i}")) }
          expect(savanna).to be_full
          expect { savanna.admit(build_adult(zebra, name: 'over')) }
            .to raise_error(Errors::CapacityExceeded)
        end

        it '気候に適応できない個体は収容できないこと' do
          cold = described_class.new(name: '極地', temperature: Shared::Temperature.celsius(-10), capacity: 2)
          expect { cold.admit(build_adult(zebra)) }.to raise_error(Errors::ClimateMismatch)
        end

        it '肉食動物を草食動物と同居させられないこと' do
          savanna.admit(build_adult(zebra))
          expect { savanna.admit(build_adult(lion)) }
            .to raise_error(Errors::IncompatibleCohabitation)
        end

        it '死亡個体は収容できないこと' do
          dead = build_adult(zebra).die
          expect { savanna.admit(dead) }.to raise_error(Errors::DeadAnimal)
        end

        describe '#can_admit? / #rejection_reason(例外を投げない収容判定)' do
          it '収容できる個体は can_admit? が true、rejection_reason が nil であること' do
            expect(savanna.can_admit?(build_adult(zebra))).to be(true)
            expect(savanna.rejection_reason(build_adult(zebra))).to be_nil
          end

          it '収容できない個体は can_admit? が false、rejection_reason に理由が入ること' do
            savanna.admit(build_adult(zebra))
            lion_animal = build_adult(lion)
            expect(savanna.can_admit?(lion_animal)).to be(false)
            expect(savanna.rejection_reason(lion_animal)).to include('捕食')
          end
        end

        it '退去させると頭数が減ること' do
          z = build_adult(zebra)
          savanna.admit(z)
          savanna.release(z)
          expect(savanna).to be_empty
        end

        it '広さを指定しなければ定員×100m²になること' do
          expect(savanna.area_sqm).to eq(300)
        end

        describe '#required_area / #overcrowded?' do
          def pen(capacity, temp)
            described_class.new(name: '区画', temperature: Shared::Temperature.celsius(temp), capacity: capacity)
          end

          it '収容個体の必要面積を合計すること' do
            enclosure = pen(4, 28)
            enclosure.admit(build_adult(zebra, name: 'z1'))
            enclosure.admit(build_adult(zebra, name: 'z2'))
            expect(enclosure.required_area).to eq(200.0)
          end

          it '空のエリアは過密でないこと' do
            expect(pen(2, 28)).not_to be_overcrowded
          end

          it '必要面積が広さを超えると過密であること' do
            enclosure = pen(1, 25)
            enclosure.admit(build_adult(giraffe))
            expect(enclosure).to be_overcrowded
          end
        end

        describe '#subordinate_male?' do
          def pride
            described_class.new(name: '丘', temperature: Shared::Temperature.celsius(28), capacity: 6)
          end

          it '成熟オスが複数いると、年長でない方が序列下位であること' do
            enclosure = pride
            senior = build_animal(lion, name: '長老', sex: Animal::Sex.male, age_in_days: 4000)
            junior = build_adult(lion, name: '若', sex: Animal::Sex.male)
            enclosure.admit(senior)
            enclosure.admit(junior)
            expect(enclosure.subordinate_male?(junior)).to be(true)
            expect(enclosure.subordinate_male?(senior)).to be(false)
          end

          it 'オス1頭・メス・未成熟は序列下位でないこと' do
            enclosure = pride
            male = build_adult(lion, sex: Animal::Sex.male)
            female = build_adult(lion, sex: Animal::Sex.female)
            cub = build_animal(lion, name: '仔', sex: Animal::Sex.male, age_in_days: 0)
            [male, female, cub].each { |a| enclosure.admit(a) }
            expect(enclosure.subordinate_male?(male)).to be(false)
            expect(enclosure.subordinate_male?(female)).to be(false)
            expect(enclosure.subordinate_male?(cub)).to be(false)
          end
        end

        describe '#pass_day' do
          it '収容個体が歳をとり、エリアが汚れること' do
            savanna.admit(build_adult(zebra))
            expect { savanna.pass_day }.to change { savanna.cleanliness.level }.by(-1)
          end

          it '死亡した個体を取り除いて返すこと' do
            old_zebra = build_animal(zebra, age_in_days: 365 * 20)
            savanna.admit(old_zebra)
            dead = savanna.pass_day
            expect(dead).to include(old_zebra)
            expect(savanna).to be_empty
          end

          it '不衛生(filthy)なエリアでは健康な個体が発病すること' do
            zebra_animal = build_adult(zebra)
            savanna.admit(zebra_animal)
            savanna.soil(80)

            savanna.pass_day

            expect(zebra_animal).to be_sick
          end

          it '清潔なエリアでは発病しないこと' do
            zebra_animal = build_adult(zebra)
            savanna.admit(zebra_animal)

            savanna.pass_day

            expect(zebra_animal).not_to be_sick
          end

          it '群れ性の個体を一頭だけ収容すると、孤独で日々ストレスが増すこと' do
            lone_zebra = build_adult(zebra)
            savanna.admit(lone_zebra)

            expect { savanna.pass_day }.to change { lone_zebra.stress.level }.by_at_least(1)
          end

          it '仲間がいて清潔・適温なら、ストレスは増えないこと' do
            a = build_adult(zebra, name: 'a')
            b = build_adult(zebra, name: 'b', sex: Animal::Sex.female)
            savanna.admit(a)
            savanna.admit(b)

            savanna.pass_day

            expect(a.stress).to be_calm
          end

          it '刺激が日々 ENRICHMENT_DECAY_PER_DAY ぶん薄れること' do
            expect { savanna.pass_day }
              .to change { savanna.enrichment.level }.by(-described_class::ENRICHMENT_DECAY_PER_DAY)
          end
        end

        describe '環境エンリッチメント' do
          it '新設エリアは刺激が満ちており殺風景でないこと' do
            expect(savanna).not_to be_barren
          end

          it 'deplete_enrichment で刺激が枯れると barren? になること' do
            savanna.deplete_enrichment(100)
            expect(savanna).to be_barren
          end

          it 'enrich で刺激を補充すると barren? が解けること' do
            savanna.deplete_enrichment(100)
            savanna.enrich(100)
            expect(savanna).not_to be_barren
          end
        end
      end
    end
  end
end
