# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Condition do
      def lion
        build_adult(SpeciesCatalog.lion)
      end

      describe '.score' do
        it '個体がいなければ中立(NEUTRAL=50)を返すこと' do
          expect(described_class.score([])).to eq(Condition::NEUTRAL)
        end

        it '生存個体がいなければ(全頭死亡)中立(50)を返すこと' do
          expect(described_class.score([lion.die])).to eq(50)
        end

        it '生存個体の visible_condition の平均になること(健康100とストレス60で80)' do
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
