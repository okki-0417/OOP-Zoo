# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExhibitCondition do
  describe '#score' do
    it '生存個体がいなければ中立値(NEUTRAL=50)を返すこと' do
      expect(described_class.new([]).score).to eq(described_class::NEUTRAL)
    end

    it '生存個体の visible_condition の平均を返すこと' do
      healthy = build_adult(SpeciesCatalog.lion)
      stressed = build_adult(SpeciesCatalog.lion)
      stressed.add_stress(70)

      average = (healthy.visible_condition + stressed.visible_condition) / 2
      expect(described_class.new([healthy, stressed]).score).to eq(average)
    end

    it '死亡個体は平均から除外されること' do
      alive = build_adult(SpeciesCatalog.lion)
      dead = build_adult(SpeciesCatalog.lion)
      dead.die

      expect(described_class.new([alive, dead]).score).to eq(alive.visible_condition)
    end
  end
end
