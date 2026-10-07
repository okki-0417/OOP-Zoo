# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Contagion do
  subject(:contagion) { described_class.new(enclosure, Occupancy.new(enclosure:, occupants:)) }

  let(:enclosure) { build(:enclosure, capacity: 6) }

  describe '#spread' do
    context '感染源がいないとき' do
      let(:occupants) { [build(:animal), build(:animal)] }

      it '誰も発病させず [] を返すこと' do
        expect(contagion.spread).to eq([])
      end
    end

    context '風邪の感染源と健康な個体が同居しているとき' do
      let(:carrier) { build(:animal).tap { |animal| animal.fall_ill(IllnessCatalog.cold) } }
      let(:healthy) { build(:animal) }
      let(:occupants) { [carrier, healthy] }

      it '新たに発病した健康な個体だけを返すこと' do
        expect(contagion.spread).to contain_exactly(healthy)
      end
    end
  end
end
