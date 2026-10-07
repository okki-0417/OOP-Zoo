# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cleaning do
  let(:keeper) { Keeper.new(name: '田中', specialties: [TaxonClass.mammal]) }
  let(:enclosure) do
    Enclosure.new(name: 'サバンナ', temperature: Temperature.celsius(28), capacity: 4)
  end

  describe '#perform' do
    it '保持するエリアの清潔さを amount=100 で満タンに戻し、勤務時間を60分使うこと' do
      enclosure.soil(40)
      described_class.new(keeper: keeper, enclosure: enclosure).perform
      expect(enclosure.cleanliness.level).to eq(100)
      expect(keeper.worked_minutes).to eq(60)
    end

    it 'amount を指定するとその分だけ清潔さを回復すること' do
      enclosure.soil(100)
      described_class.new(keeper: keeper, enclosure: enclosure, amount: 30).perform
      expect(enclosure.cleanliness.level).to eq(30)
    end
  end

  it '#keeper / #enclosure で保持する飼育員とエリアを返すこと' do
    cleaning = described_class.new(keeper: keeper, enclosure: enclosure)
    expect(cleaning.keeper).to eq(keeper)
    expect(cleaning.enclosure).to eq(enclosure)
  end

  it '生成後は frozen であること' do
    expect(described_class.new(keeper: keeper, enclosure: enclosure)).to be_frozen
  end

  describe '#to_s' do
    it '飼育員がエリアを清掃 の形で表されること' do
      cleaning = described_class.new(keeper: keeper, enclosure: enclosure)
      expect(cleaning.to_s).to eq('田中がサバンナを清掃')
    end
  end
end
