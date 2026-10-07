# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '固定費と休園' do
  def savanna
    build(:enclosure, name: 'サバンナ')
  end

  describe '固定費は収入に依存しない' do
    it '在園個体がいれば、来園者のいない休園日でも運営費が発生すること' do
      daily = OperatingCost.new(
        enclosures: [savanna], staff: [build(:keeper)], species: [SpeciesCatalog.lion]
      ).amount
      expect(daily.yen).to be > 0
    end

    it '運営費は来園者数ではなく在園頭数で増えること(飼料費)' do
      one = OperatingCost.new(
        enclosures: [savanna], staff: [build(:keeper)], species: [SpeciesCatalog.lion]
      ).amount
      two = OperatingCost.new(
        enclosures: [savanna], staff: [build(:keeper)], species: [SpeciesCatalog.lion, SpeciesCatalog.african_elephant]
      ).amount
      expect(two.yen).to be > one.yen
    end

    it '同じ種でも、飼料費は頭数分かかること(ライオン3頭はライオン1頭の3倍)' do
      lions = Array.new(3) { SpeciesCatalog.lion }
      feed = ->(species) { OperatingCost.new(enclosures: [], staff: [], species:).amount }
      expect(feed.call(lions)).to eq(feed.call([SpeciesCatalog.lion]) * 3)
    end

    it '在園個体がいなくても、エリアと職員(飼育員・獣医)の維持費は発生すること' do
      staff = [build(:keeper), build(:veterinarian, name: '獣医')]
      daily = OperatingCost.new(enclosures: [savanna], staff: staff, species: []).amount
      expect(daily.yen).to be > 0
    end
  end
end
