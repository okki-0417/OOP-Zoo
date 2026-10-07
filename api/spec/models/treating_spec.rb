# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Treating do
  subject(:treating) { described_class.new(veterinarian: build(:veterinarian, name: '佐藤'), animal:) }

  let(:animal) { build(:animal, name: 'レオ') }

  describe '#perform' do
    context '肺炎にかかっているとき' do
      before { animal.fall_ill(IllnessCatalog.pneumonia) }

      it '病気を治し sick? を false にすること' do
        treating.perform

        expect(animal).not_to be_sick
      end
    end

    context '90回鳴いて衰弱しているとき' do
      before { 90.times { animal.cry_out } }

      it '体力を回復させ weak? を false にすること' do
        treating.perform

        expect(animal.weak?).to be(false)
      end
    end

    context '死亡しているとき' do
      before { animal.die }

      it 'DeadAnimal を投げること' do
        expect { treating.perform }.to raise_error(Errors::DeadAnimal)
      end
    end
  end

  describe '#to_s' do
    it '"佐藤がレオを治療" を返すこと' do
      expect(treating.to_s).to eq('佐藤がレオを治療')
    end
  end
end
