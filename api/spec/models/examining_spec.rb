# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Examining do
  subject(:examining) { described_class.new(veterinarian: build(:veterinarian, name: '佐藤'), animal:) }

  let(:animal) { build(:animal, name: 'レオ') }

  describe '#diagnosis' do
    context '異常がないとき' do
      it ':healthy を返すこと' do
        expect(examining.diagnosis).to eq(:healthy)
      end
    end

    context '肺炎にかかっているとき' do
      before { animal.fall_ill(IllnessCatalog.pneumonia) }

      it ':sick を返すこと' do
        expect(examining.diagnosis).to eq(:sick)
      end
    end

    context '90回鳴いて衰弱しているとき' do
      before { 90.times { animal.cry_out } }

      it ':injured を返すこと' do
        expect(examining.diagnosis).to eq(:injured)
      end
    end

    context '死亡しているとき' do
      before { animal.die }

      it ':dead を返すこと' do
        expect(examining.diagnosis).to eq(:dead)
      end
    end
  end

  describe '#to_s' do
    it '"佐藤がレオを診察" を返すこと' do
      expect(examining.to_s).to eq('佐藤がレオを診察')
    end
  end
end
