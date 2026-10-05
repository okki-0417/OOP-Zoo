# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Prognosis do
  catalog   = Zoo::Domain::SpeciesCatalog
  illnesses = Zoo::Domain::IllnessCatalog

  let(:enclosure) do
    Zoo::Domain::Enclosure.new(name: '丘', temperature: Zoo::Domain::Shared::Temperature.celsius(25), capacity: 4)
  end
  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:mate) { build_adult(catalog.lion, name: 'ナラ', sex: Zoo::Domain::Animal::Sex.female) }

  def prognosis_of(animal, occupants = [animal, mate])
    described_class.new(
      animal:, enclosure:, occupancy: build_occupancy(enclosure, occupants), season: Zoo::Domain::Season.spring
    )
  end

  describe '#days_to_death / #cause_of_death' do
    it '死亡済みの個体は days_to_death も cause_of_death も nil を返すこと' do
      lion.die(cause: :old_age)
      expect(prognosis_of(lion).days_to_death).to be_nil
      expect(prognosis_of(lion).cause_of_death).to be_nil
    end

    it 'ライオンが肺炎のとき days_to_death=12・cause_of_death=:illness を返すこと' do
      lion.fall_ill(illnesses.pneumonia)
      expect(prognosis_of(lion).days_to_death).to eq(12)
      expect(prognosis_of(lion).cause_of_death).to eq(:illness)
    end

    it 'HORIZON_DAYS(30日)を超えて生きる見込みなら nil を返すこと' do
      lone = build_adult(catalog.lion, name: '孤独')
      expect(prognosis_of(lone, [lone]).days_to_death).to be_nil
    end

    it '見積もりは一度だけ行い、2回目の呼び出しでは AnimalDay を再実行しないこと' do
      prognosis = prognosis_of(lion)
      prognosis.days_to_death
      allow(Zoo::Domain::AnimalDay).to receive(:new).and_call_original
      prognosis.cause_of_death
      expect(Zoo::Domain::AnimalDay).not_to have_received(:new)
    end
  end

  describe '#outlook' do
    {
      nil => :good, 1 => :grave, 3 => :grave, 4 => :guarded, 14 => :guarded, 15 => :good
    }.each do |days, expected|
      it "days_to_death が #{days.inspect} のとき :#{expected} を返すこと" do
        prognosis = prognosis_of(lion)
        allow(prognosis).to receive(:days_to_death).and_return(days)
        expect(prognosis.outlook).to eq(expected)
      end
    end
  end

  describe '元の集約を変えないこと' do
    it '不潔なエリアで見積もっても、元の個体は発病せず免疫も増えず、エリアの清潔度・刺激度も変わらないこと' do
      enclosure.soil(80)
      expect { prognosis_of(lion).days_to_death }
        .not_to(change { [lion.illness, lion.immunities, lion.meals, enclosure.cleanliness_level, enclosure.enrichment] })
    end
  end
end
