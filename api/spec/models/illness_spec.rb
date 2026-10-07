# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal::Illness do
  subject(:illness) { described_class.new(name_ja:, daily_damage:, **options) }

  let(:name_ja) { '風邪' }
  let(:daily_damage) { 2 }
  let(:options) { {} }

  describe '.new' do
    context "name_ja='風邪'・daily_damage=2 のとき" do
      it 'name_ja が "風邪"・daily_damage が 2 になること' do
        expect(illness).to have_attributes(name_ja: '風邪', daily_damage: 2)
      end
    end

    context 'name_ja が空文字のとき' do
      let(:name_ja) { '' }

      it 'ArgumentError が発生すること' do
        expect { illness }.to raise_error(ArgumentError)
      end
    end

    context 'daily_damage が 0 のとき' do
      let(:daily_damage) { 0 }

      it 'ArgumentError が発生すること' do
        expect { illness }.to raise_error(ArgumentError)
      end
    end

    context 'daily_damage が Integer 以外の 1.5 のとき' do
      let(:daily_damage) { 1.5 }

      it 'ArgumentError が発生すること' do
        expect { illness }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#contagious?' do
    context 'contagious を省略したとき' do
      it 'false を返すこと' do
        expect(illness).not_to be_contagious
      end
    end

    context 'contagious: true のとき' do
      let(:options) { { contagious: true } }

      it 'true を返すこと' do
        expect(illness).to be_contagious
      end
    end

    context 'contagious: false のとき' do
      let(:options) { { contagious: false } }

      it 'false を返すこと' do
        expect(illness).not_to be_contagious
      end
    end
  end

  describe '#severe?' do
    context 'daily_damage が閾値ちょうどの 5 のとき' do
      let(:daily_damage) { 5 }

      it 'true を返すこと' do
        expect(illness).to be_severe
      end
    end

    context 'daily_damage が 4 のとき' do
      let(:daily_damage) { 4 }

      it 'false を返すこと' do
        expect(illness).not_to be_severe
      end
    end
  end

  describe '#to_s' do
    it 'name_ja の "風邪" を返すこと' do
      expect(illness.to_s).to eq('風邪')
    end
  end

  describe '#==' do
    let(:options) { { contagious: true } }

    context 'name_ja・daily_damage・contagious がすべて同じとき' do
      it '等しいこと' do
        expect(illness).to eq(described_class.new(name_ja: '風邪', daily_damage: 2, contagious: true))
      end
    end

    context 'daily_damage が 2 と 3 で違うとき' do
      it '等しくないこと' do
        expect(illness).not_to eq(described_class.new(name_ja: '風邪', daily_damage: 3, contagious: true))
      end
    end
  end
end

RSpec.describe IllnessCatalog do
  describe '.all' do
    it 'keys と同数の疾病を返し、風邪を含むこと' do
      expect(described_class.all.size).to eq(described_class.keys.size)
      expect(described_class.all).to include(described_class.cold)
    end
  end

  describe '.find' do
    context '未知のキー :unknown のとき' do
      it 'nil を返すこと' do
        expect(described_class.find(:unknown)).to be_nil
      end
    end
  end
end
