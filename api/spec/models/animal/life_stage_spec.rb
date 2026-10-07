# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal::LifeStage do
  describe '.for' do
    subject(:stage) { described_class.for(age_in_days:, species: SpeciesCatalog.lion) }

    context 'ライオン(性成熟3年・寿命15年)の0日齢のとき' do
      let(:age_in_days) { 0 }

      it '性成熟の半分の1.5年未満なので baby を返すこと' do
        expect(stage).to be_baby
      end
    end

    context 'ライオンの2歳(365*2日)のとき' do
      let(:age_in_days) { 365 * 2 }

      it '性成熟の半分以上〜性成熟未満なので juvenile を返すこと' do
        expect(stage.value).to eq(:juvenile)
      end
    end

    context 'ライオンの3歳(365*3日)のとき' do
      let(:age_in_days) { 365 * 3 }

      it '性成熟以上〜寿命の80%未満なので adult を返すこと' do
        expect(stage).to be_adult
      end
    end

    context 'ライオンの13歳(365*13日)のとき' do
      let(:age_in_days) { 365 * 13 }

      it '寿命15年の80%=12年以上なので elderly を返すこと' do
        expect(stage).to be_elderly
      end
    end
  end

  describe '.new' do
    context '未知のシンボル :unknown を渡したとき' do
      it 'ArgumentError を投げること' do
        expect { described_class.new(:unknown) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.baby / .juvenile / .adult / .elderly' do
    it 'それぞれ value が :baby / :juvenile / :adult / :elderly の LifeStage を返すこと' do
      expect(described_class.baby.value).to eq(:baby)
      expect(described_class.juvenile.value).to eq(:juvenile)
      expect(described_class.adult.value).to eq(:adult)
      expect(described_class.elderly.value).to eq(:elderly)
    end
  end

  describe '#baby?' do
    it '.baby は true・.juvenile は false を返すこと' do
      expect(described_class.baby).to be_baby
      expect(described_class.juvenile).not_to be_baby
    end
  end

  describe '#adult?' do
    it '.adult は true・.elderly は false(老齢は adult? に含まれない)を返すこと' do
      expect(described_class.adult).to be_adult
      expect(described_class.elderly).not_to be_adult
    end
  end

  describe '#elderly?' do
    it '.elderly は true を返すこと' do
      expect(described_class.elderly).to be_elderly
    end
  end

  describe '#mature?' do
    it '.adult・.elderly は true、.baby・.juvenile は false を返すこと' do
      expect(described_class.adult).to be_mature
      expect(described_class.elderly).to be_mature
      expect(described_class.baby).not_to be_mature
      expect(described_class.juvenile).not_to be_mature
    end
  end

  describe '#label' do
    it "'幼体' / '若齢' / '成体' / '老齢' を返すこと" do
      expect(described_class.baby.label).to eq('幼体')
      expect(described_class.juvenile.label).to eq('若齢')
      expect(described_class.adult.label).to eq('成体')
      expect(described_class.elderly.label).to eq('老齢')
    end
  end

  describe '#==' do
    it '.baby と .new(:baby) が等しいこと' do
      expect(described_class.baby).to eq(described_class.new(:baby))
    end
  end
end
