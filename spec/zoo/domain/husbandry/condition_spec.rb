# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    module Husbandry
      RSpec.describe Condition do
        def lion
          build_adult(Taxonomy::SpeciesCatalog.lion)
        end

        describe '.score' do
          it '個体がいなければ中立(NEUTRAL=50)を返すこと' do
            expect(described_class.score([])).to eq(Condition::NEUTRAL)
          end

          it '生存個体がいなければ(全頭死亡)中立(50)を返すこと' do
            expect(described_class.score([lion.die])).to eq(50)
          end

          it '健康で落ち着いた1頭は満点(100)になること' do
            expect(described_class.score([lion])).to eq(100)
          end

          it 'ストレス個体は STRESSED_PENALTY(40)を引いた60になること' do
            expect(described_class.score([lion.tap { |a| a.add_stress(70) }])).to eq(60)
          end

          it '病気の個体は SICK_PENALTY(40)を引いた60になること' do
            sick = lion.tap { |a| a.fall_ill(Medical::IllnessCatalog.parasite) }
            expect(described_class.score([sick])).to eq(60)
          end

          it 'ストレスと病気が重なると両方引かれること(100-40-40=20)' do
            both = lion.tap do |a|
              a.add_stress(70)
              a.fall_ill(Medical::IllnessCatalog.parasite)
            end
            expect(described_class.score([both])).to eq(20)
          end

          it '生存個体の平均になること(健康100とストレス60で80)' do
            stressed = lion.tap { |a| a.add_stress(70) }
            expect(described_class.score([lion, stressed])).to eq(80)
          end

          it '死亡個体は平均から除外されること(健康1頭+死亡1頭なら100)' do
            expect(described_class.score([lion, lion.die])).to eq(100)
          end
        end
      end
    end
  end
end
