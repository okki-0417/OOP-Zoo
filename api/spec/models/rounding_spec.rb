# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rounding do
  subject(:rounding) do
    described_class.new(keeper:, occupancy: Occupancy.new(enclosure:, occupants:), foods: FoodCatalog.all)
  end

  let(:keeper) { build(:keeper, name: '飼育員') }
  let(:enclosure) { build(:enclosure, name: '丘', celsius: 24) }
  let(:occupants) { [] }

  describe '#perform' do
    subject(:report) { rounding.perform }

    context '飼育員が丘の担当のとき' do
      before { keeper.enclosures << enclosure }

      context '住人が死亡個体だけのとき' do
        let(:occupants) { [build(:animal).die] }

        it 'fed が空であること' do
          expect(report.fed).to eq([])
        end
      end

      context '清潔で刺激も十分な丘に生きた個体が1頭いるとき' do
        let(:occupants) { [build(:animal)] }

        it 'cleaned=false・enriched=false・skipped=[] で、給餌1頭ぶんの10分だけ勤務時間を使うこと' do
          expect(report).to have_attributes(enclosure:, cleaned: false, enriched: false, skipped: [])
          expect(keeper.worked_minutes).to eq(10)
        end
      end

      context '清潔度が SOILED_THRESHOLD(70)を上回る71のとき' do
        before { enclosure.soil(29) }

        it '清掃しないこと' do
          expect(report).not_to be_cleaned
        end
      end

      context '清潔度が SOILED_THRESHOLD ちょうどの70のとき' do
        before { enclosure.soil(30) }

        it '清掃すること' do
          expect(report).to be_cleaned
        end
      end

      context '刺激度が DULL_THRESHOLD(50)を上回る51のとき' do
        before { enclosure.deplete_enrichment(49) }

        it '補充しないこと' do
          expect(report).not_to be_enriched
        end
      end

      context '刺激度が DULL_THRESHOLD ちょうどの50のとき' do
        before { enclosure.deplete_enrichment(50) }

        it '補充すること' do
          expect(report).to be_enriched
        end
      end
    end

    context '飼育員が丘の担当でないとき' do
      let(:lion) { build(:animal).get_hungrier(50) }
      let(:occupants) { [lion] }

      it "WorkNotAllowed('飼育員飼育員は丘の担当ではありません')を投げ、空腹度50のままにすること" do
        expect { report }.to raise_error(Errors::WorkNotAllowed, '飼育員飼育員は丘の担当ではありません')
        expect(lion.hunger_level).to eq(50)
      end
    end
  end
end
