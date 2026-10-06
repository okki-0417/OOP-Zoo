# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal::Meals do
  describe '.none' do
    it 'categories が空で variety が 0 の Meals を返すこと' do
      expect(described_class.none.categories).to eq([])
      expect(described_class.none.variety).to eq(0)
    end
  end

  describe '.new' do
    it "['fruit', :insect, :fruit] を渡すと重複を除いて [:fruit, :insect] に正規化されること" do
      expect(described_class.new(['fruit', :insect, :fruit]).categories).to eq(%i[fruit insect])
    end

    it '未知のカテゴリ :pizza を渡すと ArgumentError が発生すること' do
      expect { described_class.new([:pizza]) }.to raise_error(ArgumentError, /pizza/)
    end
  end

  describe '#with' do
    it '[:fruit] に with([:insect, :fruit]) すると categories が [:fruit, :insect] の新しい Meals を返すこと' do
      meals = described_class.new([:fruit])
      expect(meals.with(%i[insect fruit]).categories).to eq(%i[fruit insect])
      expect(meals.categories).to eq([:fruit])
    end
  end

  describe '#balanced_for?' do
    it '[:fruit, :insect] は balanced_for?(2) が true・balanced_for?(3) が false であること' do
      meals = described_class.new(%i[fruit insect])
      expect(meals.balanced_for?(2)).to be(true)
      expect(meals.balanced_for?(3)).to be(false)
    end
  end

  describe '#to_s' do
    it '空なら "欠食"、[:fruit, :insect] なら "fruit・insect" を返すこと' do
      expect(described_class.none.to_s).to eq('欠食')
      expect(described_class.new(%i[insect fruit]).to_s).to eq('fruit・insect')
    end
  end

  describe '#==' do
    it '順序違いの同じカテゴリ集合は等価であること' do
      expect(described_class.new(%i[fruit insect])).to eq(described_class.new(%i[insect fruit]))
    end
  end
end
