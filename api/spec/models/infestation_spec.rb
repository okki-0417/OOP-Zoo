# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Infestation do
  subject(:infestation) { described_class.new(enclosure, Occupancy.new(enclosure:, occupants: [animal])) }

  let(:enclosure) { build(:enclosure, capacity: 6) }
  let(:animal) { build(:animal) }

  describe '#spread' do
    context '清潔なエリアのとき' do
      it '誰も発病させず [] を返すこと' do
        expect(infestation.spread).to eq([])
        expect(animal).not_to be_sick
      end
    end

    context 'soil(80) で不潔なエリアのとき' do
      before { enclosure.soil(80) }

      it '健康な個体を寄生虫で発病させ、その個体を返すこと' do
        expect(infestation.spread).to contain_exactly(animal)
        expect(animal.illness).to eq(IllnessCatalog.parasite)
      end

      context '個体が既に風邪をひいているとき' do
        let(:animal) { build(:animal).fall_ill(IllnessCatalog.cold) }

        it '感受性がないので発病させず [] を返すこと' do
          expect(infestation.spread).to eq([])
        end
      end
    end
  end
end
