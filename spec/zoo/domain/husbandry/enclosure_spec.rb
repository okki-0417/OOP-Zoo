# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    module Husbandry
      RSpec.describe CohabitationPolicy do
        let(:lion) { Taxonomy::SpeciesCatalog.lion }
        let(:zebra) { Taxonomy::SpeciesCatalog.grevys_zebra }
        let(:giraffe) { Taxonomy::SpeciesCatalog.reticulated_giraffe }
        let(:polar_bear) { Taxonomy::SpeciesCatalog.polar_bear }
        let(:penguin) { Taxonomy::SpeciesCatalog.emperor_penguin }

        it '草食動物同士は混合展示できること' do
          expect(described_class.compatible?(zebra, giraffe)).to be(true)
        end

        it '肉食動物は異種と同居できないこと' do
          expect(described_class.compatible?(lion, zebra)).to be(false)
        end

        it '群れで暮らす種は同種を同居できること' do
          expect(described_class.compatible?(lion, lion)).to be(true)
        end

        it '単独性の種は同種でも同居できないこと' do
          expect(described_class.compatible?(polar_bear, polar_bear)).to be(false)
        end

        it '適温域が両立しない種同士は同居できないこと' do
          expect(described_class.compatible?(lion, penguin)).to be(false)
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

        it '退去させると頭数が減ること' do
          z = build_adult(zebra)
          savanna.admit(z)
          savanna.release(z)
          expect(savanna).to be_empty
        end

        it '広さを指定しなければ定員×100m²になること' do
          expect(savanna.area_sqm).to eq(300) # 定員3
        end

        describe '#pass_day' do
          it '収容個体が歳をとり、エリアが汚れること' do
            savanna.admit(build_adult(zebra))
            expect { savanna.pass_day }.to change { savanna.cleanliness.level }.by(-1)
          end

          it '死亡した個体を取り除いて返すこと' do
            old_zebra = build_animal(zebra, age_in_days: 365 * 20) # 寿命ぎりぎり
            savanna.admit(old_zebra)
            dead = savanna.pass_day
            expect(dead).to include(old_zebra)
            expect(savanna).to be_empty
          end

          it '不衛生(filthy)なエリアでは健康な個体が発病すること' do
            zebra_animal = build_adult(zebra)
            savanna.admit(zebra_animal)
            savanna.soil(80) # 清潔度100→20で filthy

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
            b = build_adult(zebra, name: 'b')
            savanna.admit(a)
            savanna.admit(b)

            savanna.pass_day

            expect(a.stress).to be_calm
          end
        end
      end
    end
  end
end
