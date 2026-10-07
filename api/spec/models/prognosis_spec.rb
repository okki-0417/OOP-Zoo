# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Prognosis do
  subject(:prognosis) { described_class.new(animal:, enclosure:, occupancy:, season: Season.spring) }

  let(:enclosure) { build(:enclosure, name: '丘', celsius: 25) }
  let(:animal) { build(:animal, name: 'レオ') }
  let(:occupants) { [animal, build(:animal, :female, name: 'ナラ')] }
  let(:occupancy) { Occupancy.new(enclosure:, occupants:) }

  describe '#days_to_death' do
    context '死亡済みのとき' do
      let(:animal) { build(:animal).die(cause: :old_age) }

      it 'nil を返すこと' do
        expect(prognosis.days_to_death).to be_nil
      end
    end

    context 'ライオンが肺炎のとき' do
      before { animal.fall_ill(IllnessCatalog.pneumonia) }

      it '12 を返すこと' do
        expect(prognosis.days_to_death).to eq(12)
      end
    end

    context 'HORIZON_DAYS(30日)を超えて生きる見込みのとき' do
      let(:occupants) { [animal] }

      it 'nil を返すこと' do
        expect(prognosis.days_to_death).to be_nil
      end
    end

    context '不潔なエリアのとき' do
      before { enclosure.soil(80) }

      it '元の個体の病気・免疫・食事と、エリアの清潔度・刺激度を変えないこと' do
        expect { prognosis.days_to_death }
          .not_to(change { [animal.illness, animal.immunities, animal.meals, enclosure.cleanliness_level, enclosure.enrichment] })
      end
    end
  end

  describe '#cause_of_death' do
    context '死亡済みのとき' do
      let(:animal) { build(:animal).die(cause: :old_age) }

      it 'nil を返すこと' do
        expect(prognosis.cause_of_death).to be_nil
      end
    end

    context 'ライオンが肺炎のとき' do
      before { animal.fall_ill(IllnessCatalog.pneumonia) }

      it ':illness を返すこと' do
        expect(prognosis.cause_of_death).to eq(:illness)
      end
    end

    context '#days_to_death で見積もり済みのとき' do
      before do
        prognosis.days_to_death
        allow(AnimalDay).to receive(:new).and_call_original
      end

      it 'AnimalDay を再実行しないこと' do
        prognosis.cause_of_death

        expect(AnimalDay).not_to have_received(:new)
      end
    end
  end

  describe '#outlook' do
    before { allow(prognosis).to receive(:days_to_death).and_return(days_to_death) }

    { nil => :good, 1 => :grave, 3 => :grave, 4 => :guarded, 14 => :guarded, 15 => :good }.each do |days, expected|
      context "days_to_death が #{days.inspect} のとき" do
        let(:days_to_death) { days }

        it ":#{expected} を返すこと" do
          expect(prognosis.outlook).to eq(expected)
        end
      end
    end
  end
end
