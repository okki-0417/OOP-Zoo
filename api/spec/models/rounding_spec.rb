# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rounding do
  let(:keeper) { build(:keeper, name: '飼育員') }
  let(:enclosure) do
    build(:enclosure, name: '丘', celsius: 24)
  end

  def rounding(occupants)
    keeper.enclosures << enclosure unless keeper.in_charge_of?(enclosure)
    described_class.new(
      keeper:, occupancy: Occupancy.new(enclosure: enclosure, occupants: occupants), foods: FoodCatalog.all
    )
  end

  describe '#perform' do
    it '死亡個体には給餌しないこと' do
      dead = build(:animal).die
      expect(rounding([dead]).perform.fed).to eq([])
    end

    it '清潔で刺激も十分なエリアでは cleaned=false・enriched=false で、給餌1頭ぶん(10分)だけ勤務時間を使うこと' do
      report = rounding([build(:animal)]).perform

      expect(report).to have_attributes(enclosure:, cleaned: false, enriched: false, skipped: [])
      expect(keeper.worked_minutes).to eq(10)
    end

    it '清潔度71では清掃せず、70では清掃すること(Cleanliness::SOILED_THRESHOLD=70)' do
      enclosure.soil(29)
      expect(rounding([]).perform).not_to be_cleaned
      enclosure.soil(1)
      expect(rounding([]).perform).to be_cleaned
    end

    it '刺激度51では補充せず、50では補充すること(Enrichment::DULL_THRESHOLD=50)' do
      enclosure.deplete_enrichment(49)
      expect(rounding([]).perform).not_to be_enriched
      enclosure.deplete_enrichment(1)
      expect(rounding([]).perform).to be_enriched
    end

    it '担当でない飼育員は WorkNotAllowed になり、何も変えないこと' do
      lion = build(:animal).get_hungrier(50)
      unassigned = described_class.new(
        keeper:, occupancy: Occupancy.new(enclosure: enclosure, occupants: [lion]), foods: FoodCatalog.all
      )

      expect { unassigned.perform }.to raise_error(Errors::WorkNotAllowed, '飼育員飼育員は丘の担当ではありません')
      expect(lion.hunger_level).to eq(50)
    end
  end
end
