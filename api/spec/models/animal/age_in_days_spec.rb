# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal::AgeInDays do
  subject(:age) { described_class.new(value) }

  let(:value) { 0 }
  let(:lion) { SpeciesCatalog.lion }

  describe '.new' do
    context 'value が 0 のとき' do
      it 'value 0 を返すこと' do
        expect(age.value).to eq(0)
      end
    end

    context 'value が -1 のとき' do
      let(:value) { -1 }

      it 'ArgumentError が発生すること' do
        expect { age }.to raise_error(ArgumentError)
      end
    end

    context 'value が Integer 以外の 1.5 のとき' do
      let(:value) { 1.5 }

      it 'ArgumentError が発生すること' do
        expect { age }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.zero' do
    it '.new(0) と等しい AgeInDays を返すこと' do
      expect(described_class.zero).to eq(described_class.new(0))
    end
  end

  describe '#advanced_by' do
    let(:value) { 10 }

    context '5 を渡したとき' do
      it 'value 15 の AgeInDays を返し、元の value は 10 のままであること' do
        expect(age.advanced_by(5).value).to eq(15)
        expect(age.value).to eq(10)
      end
    end

    context '0 を渡したとき' do
      it 'ArgumentError が発生すること' do
        expect { age.advanced_by(0) }.to raise_error(ArgumentError)
      end
    end

    context '-1 を渡したとき' do
      it 'ArgumentError が発生すること' do
        expect { age.advanced_by(-1) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#years' do
    context 'value が 365*2+10 のとき' do
      let(:value) { (365 * 2) + 10 }

      it '端数を切り捨てた 2 を返すこと' do
        expect(age.years).to eq(2)
      end
    end

    context 'value が 0 のとき' do
      it '0 を返すこと' do
        expect(age.years).to eq(0)
      end
    end
  end

  describe '#life_stage' do
    context 'value が 0 のとき' do
      it 'ライオンでは幼体(baby)を返すこと' do
        expect(age.life_stage(lion)).to be_baby
      end
    end

    context 'value が性成熟の 365*3 のとき' do
      let(:value) { 365 * 3 }

      it 'ライオンでは成体(adult)を返すこと' do
        expect(age.life_stage(lion)).to be_adult
      end
    end

    context 'value が寿命の80%を超える 365*13 のとき' do
      let(:value) { 365 * 13 }

      it 'ライオンでは老齢(elderly)を返すこと' do
        expect(age.life_stage(lion)).to be_elderly
      end
    end
  end

  describe '#mature?' do
    context 'value が 365*3 のとき' do
      let(:value) { 365 * 3 }

      it 'ライオンでは true を返すこと' do
        expect(age.mature?(lion)).to be(true)
      end
    end

    context 'value が 0 のとき' do
      it 'ライオンでは false を返すこと' do
        expect(age.mature?(lion)).to be(false)
      end
    end
  end

  describe '#past_lifespan?' do
    context 'value が寿命15年を超える 365*16 のとき' do
      let(:value) { 365 * 16 }

      it 'ライオンでは true を返すこと' do
        expect(age.past_lifespan?(lion)).to be(true)
      end
    end

    context 'value が寿命と同じ 365*15 のとき' do
      let(:value) { 365 * 15 }

      it 'ライオンでは false を返すこと' do
        expect(age.past_lifespan?(lion)).to be(false)
      end
    end
  end

  describe '#past_breeding_age?' do
    context 'value が寿命15年の8割ちょうどの 365*12 のとき' do
      let(:value) { 365 * 12 }

      it 'ライオンでは true を返すこと' do
        expect(age.past_breeding_age?(lion)).to be(true)
      end
    end

    context 'value が8割未満の 365*11 のとき' do
      let(:value) { 365 * 11 }

      it 'ライオンでは false を返すこと' do
        expect(age.past_breeding_age?(lion)).to be(false)
      end
    end
  end

  describe '#weaned?' do
    context 'value が離乳適齢ちょうどの 219 のとき' do
      let(:value) { 219 }

      it 'ライオンでは true を返すこと' do
        expect(age.weaned?(lion)).to be(true)
      end
    end

    context 'value が離乳適齢未満の 218 のとき' do
      let(:value) { 218 }

      it 'ライオンでは false を返すこと' do
        expect(age.weaned?(lion)).to be(false)
      end
    end
  end

  describe '#<=>' do
    let(:value) { 10 }

    it 'value 10 は value 20 より小さく、value 20 は value 10 より大きいこと' do
      expect(age).to be < described_class.new(20)
      expect(described_class.new(20)).to be > age
    end
  end

  describe '#==' do
    let(:value) { 10 }

    it 'value 10 同士は等しいこと' do
      expect(age).to eq(described_class.new(10))
    end
  end
end
