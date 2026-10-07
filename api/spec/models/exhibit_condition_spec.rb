# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExhibitCondition do
  subject(:exhibit_condition) { described_class.new(animals) }

  describe '#score' do
    context '生存個体がいないとき' do
      let(:animals) { [] }

      it '中立値 NEUTRAL(50) を返すこと' do
        expect(exhibit_condition.score).to eq(described_class::NEUTRAL)
      end
    end

    context '健康な個体(100)とストレス70の個体(60)がいるとき' do
      let(:animals) { [build(:animal), build(:animal).tap { |animal| animal.add_stress(70) }] }

      it 'visible_condition の平均 80 を返すこと' do
        expect(exhibit_condition.score).to eq(80)
      end
    end

    context '健康な個体(100)と死亡個体がいるとき' do
      let(:animals) { [build(:animal), build(:animal).tap(&:die)] }

      it '死亡個体を除いた 100 を返すこと' do
        expect(exhibit_condition.score).to eq(100)
      end
    end
  end
end
