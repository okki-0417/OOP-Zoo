# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Animal::Meals do
  subject(:meals) { described_class.new(categories) }

  let(:categories) { %i[fruit insect] }

  describe '.none' do
    it 'categories が [] で variety が 0 の Meals を返すこと' do
      expect(described_class.none).to have_attributes(categories: [], variety: 0)
    end
  end

  describe '.new' do
    context "['fruit', :insect, :fruit] を渡したとき" do
      let(:categories) { ['fruit', :insect, :fruit] }

      it '重複を除いて categories を [:fruit, :insect] に正規化すること' do
        expect(meals.categories).to eq(%i[fruit insect])
      end
    end

    context '未知のカテゴリ :pizza を渡したとき' do
      let(:categories) { [:pizza] }

      it 'pizza を含む ArgumentError を投げること' do
        expect { meals }.to raise_error(ArgumentError, /pizza/)
      end
    end
  end

  describe '#with' do
    let(:categories) { [:fruit] }

    it '[:fruit] に with([:insect, :fruit]) すると categories が [:fruit, :insect] の新しい Meals を返し、元は [:fruit] のままであること' do
      expect(meals.with(%i[insect fruit]).categories).to eq(%i[fruit insect])
      expect(meals.categories).to eq([:fruit])
    end
  end

  describe '#balanced_for?' do
    it '[:fruit, :insect] は balanced_for?(2) で true を返すこと' do
      expect(meals.balanced_for?(2)).to be(true)
    end

    it '[:fruit, :insect] は balanced_for?(3) で false を返すこと' do
      expect(meals.balanced_for?(3)).to be(false)
    end
  end

  describe '#to_s' do
    context '空のとき' do
      let(:categories) { [] }

      it '"欠食" を返すこと' do
        expect(meals.to_s).to eq('欠食')
      end
    end

    context '[:insect, :fruit] のとき' do
      let(:categories) { %i[insect fruit] }

      it '"fruit・insect" を返すこと' do
        expect(meals.to_s).to eq('fruit・insect')
      end
    end
  end

  describe '#==' do
    it '[:fruit, :insect] と順序違いの [:insect, :fruit] は等価であること' do
      expect(meals).to eq(described_class.new(%i[insect fruit]))
    end
  end
end
