# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Birth do
  subject(:birth) { described_class.new(sire:, dam:, name:) }

  let(:species) { SpeciesCatalog.lion }
  let(:sire) { build(:animal, name: 'レオ') }
  let(:dam) { build(:animal, :female, name: 'ナラ') }
  let(:name) { 'シンバ' }
  let(:inbreeding) { 0.0 }
  let(:gestated_days) { species.gestation_period_days }

  before { dam.conceive(inbreeding:).gestate(gestated_days) }

  describe '#deliver' do
    context '妊娠期間を満たした dam のとき' do
      it '両親を parents に持つ日齢0・幼体のライオン「シンバ」を offspring にすること' do
        offspring = birth.deliver.offspring

        expect(offspring).to have_attributes(species:, name: 'シンバ', age_in_days: 0)
        expect(offspring.parents).to contain_exactly(sire, dam)
        expect(offspring.life_stage).to be_baby
      end

      it 'dam の妊娠を解くこと' do
        birth.deliver

        expect(dam).not_to be_expecting
      end

      it '近交係数0では最大体力が NEWBORN_HEALTH(50) になること' do
        expect(birth.deliver.offspring.max_health).to eq(described_class::NEWBORN_HEALTH)
      end
    end

    context 'name を省略したとき' do
      subject(:birth) { described_class.new(sire:, dam:) }

      it "offspring に種名ベースの仮名 'ライオンの赤ちゃん' が付くこと" do
        expect(birth.deliver.offspring.name).to eq('ライオンの赤ちゃん')
      end
    end

    context '近交係数0.25で受胎したとき' do
      let(:inbreeding) { 0.25 }

      it 'offspring の最大体力が約75%(50→38)に下がること' do
        expect(birth.deliver.offspring.max_health).to eq(38)
      end
    end

    context '近交係数1.0で受胎したとき' do
      let(:inbreeding) { 1.0 }

      it 'offspring の最大体力が下限の1に保たれること' do
        expect(birth.deliver.offspring.max_health).to eq(1)
      end
    end

    context '妊娠期間を満たしていない(10日目の) dam のとき' do
      let(:gestated_days) { 10 }

      it 'BreedingNotAllowed を投げること' do
        expect { birth.deliver }.to raise_error(Errors::BreedingNotAllowed)
      end
    end
  end

  describe '#deliver_litter' do
    let(:name) { '仔' }

    it '産仔数(ライオンは litter_size)ぶんの子を offspring にし、全頭が同じ両親を持つこと' do
      litter = birth.deliver_litter.offspring

      expect(litter.size).to eq(species.litter_size)
      expect(litter.map(&:parents)).to all(contain_exactly(sire, dam))
    end
  end

  describe '#to_s' do
    it "出産後は 'ライオン「シンバ」が誕生しました' を返すこと" do
      expect(birth.deliver.to_s).to eq('ライオン「シンバ」が誕生しました')
    end
  end
end
