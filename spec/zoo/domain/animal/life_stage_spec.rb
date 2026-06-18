# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal::LifeStage do
  let(:lion) { Zoo::Domain::SpeciesCatalog.lion }

  describe '.for(age_in_days:, species:)' do
    it 'age=0 のライオンは baby を返すこと(性成熟3年の半分=1.5年未満)' do
      expect(described_class.for(age_in_days: 0, species: lion)).to be_baby
    end

    it 'age=365*2 のライオンは juvenile を返すこと(性成熟年齢の半分以上〜性成熟未満)' do
      expect(described_class.for(age_in_days: 365 * 2, species: lion).value).to eq(:juvenile)
    end

    it 'age=365*3 のライオンは adult を返すこと(性成熟年齢以上〜寿命の80%未満)' do
      expect(described_class.for(age_in_days: 365 * 3, species: lion)).to be_adult
    end

    it 'age=365*13 のライオンは elderly を返すこと(寿命15年の80%=12年以上)' do
      expect(described_class.for(age_in_days: 365 * 13, species: lion)).to be_elderly
    end
  end

  describe '.new(unknown_symbol)' do
    it ':unknown を渡すと ArgumentError が発生すること' do
      expect { described_class.new(:unknown) }.to raise_error(ArgumentError)
    end
  end

  describe 'ファクトリ(.baby/.juvenile/.adult/.elderly)' do
    it '対応するシンボルの LifeStage を返すこと' do
      expect(described_class.baby.value).to eq(:baby)
      expect(described_class.juvenile.value).to eq(:juvenile)
      expect(described_class.adult.value).to eq(:adult)
      expect(described_class.elderly.value).to eq(:elderly)
    end
  end

  describe '#baby?' do
    it ':baby のとき true を返すこと' do
      expect(described_class.baby).to be_baby
    end

    it ':juvenile のとき false を返すこと' do
      expect(described_class.juvenile).not_to be_baby
    end
  end

  describe '#adult?' do
    it ':adult のとき true を返すこと' do
      expect(described_class.adult).to be_adult
    end

    it ':elderly のとき false を返すこと(老齢は adult? に含まれない)' do
      expect(described_class.elderly).not_to be_adult
    end
  end

  describe '#elderly?' do
    it ':elderly のとき true を返すこと' do
      expect(described_class.elderly).to be_elderly
    end
  end

  describe '#mature?' do
    it ':adult のとき true を返すこと' do
      expect(described_class.adult).to be_mature
    end

    it ':elderly のとき true を返すこと(性成熟済み扱い)' do
      expect(described_class.elderly).to be_mature
    end

    it ':baby のとき false を返すこと' do
      expect(described_class.baby).not_to be_mature
    end

    it ':juvenile のとき false を返すこと' do
      expect(described_class.juvenile).not_to be_mature
    end
  end

  describe '#label' do
    it "各ステージに対応する日本語ラベルを返すこと(:baby → '幼体' など)" do
      expect(described_class.baby.label).to eq('幼体')
      expect(described_class.juvenile.label).to eq('若齢')
      expect(described_class.adult.label).to eq('成体')
      expect(described_class.elderly.label).to eq('老齢')
    end
  end

  describe '等価性' do
    it '同じシンボル同士は eq で等しいこと' do
      expect(described_class.baby).to eq(described_class.new(:baby))
    end
  end
end
