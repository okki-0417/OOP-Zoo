# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Keeper do
      let(:mammal_keeper) do
        described_class.new(name: '田中', specialties: [TaxonClass.mammal])
      end
      let(:lion) { build_adult(SpeciesCatalog.lion) }
      let(:penguin) { build_adult(SpeciesCatalog.emperor_penguin) }

      it '専門の綱の動物を担当できること' do
        expect(mammal_keeper.specialized_in?(lion.taxon_class)).to be(true)
        expect(mammal_keeper.specialized_in?(penguin.taxon_class)).to be(false)
      end

      it 'job_title は「飼育員」であること' do
        expect(mammal_keeper.job_title).to eq('飼育員')
      end

      it '専門を持たない飼育員は無効で、専門分野のエラーが付くこと' do
        keeper = described_class.new(name: '空', specialties: [])
        expect(keeper).not_to be_valid
        expect(keeper.errors[:specialties]).to eq(['専門分野を1つ以上指定してください'])
      end

      it '名前のない飼育員は無効であること' do
        expect(described_class.new(name: '', specialties: [TaxonClass.mammal])).not_to be_valid
      end

      describe '#clock_in' do
        it 'clock_in(100) で worked_minutes=100・remaining_minutes=380 になり、self を返すこと' do
          keeper = described_class.new(name: '田中', specialties: [TaxonClass.mammal])
          expect(keeper.clock_in(100)).to be(keeper)
          expect(keeper).to have_attributes(worked_minutes: 100, remaining_minutes: 380)
        end

        it '残り20分で clock_in(30) すると WorkNotAllowed になり、勤務時間は変わらないこと' do
          keeper = described_class.new(name: '田中', specialties: [TaxonClass.mammal]).clock_in(460)
          expect { keeper.clock_in(30) }.to raise_error(Errors::WorkNotAllowed, '飼育員田中は今日の勤務時間が足りません(残り20分)')
          expect(keeper.worked_minutes).to eq(460)
        end
      end

      describe '#available_for? / #end_shift' do
        it '残り20分なら available_for?(20) は true・(21) は false、end_shift で480分に戻ること' do
          keeper = described_class.new(name: '田中', specialties: [TaxonClass.mammal]).clock_in(460)
          expect(keeper.available_for?(20)).to be(true)
          expect(keeper.available_for?(21)).to be(false)
          expect(keeper.end_shift.remaining_minutes).to eq(480)
        end
      end

      describe '保存と再読込' do
        it '専門[哺乳類・鳥類]・勤務200分で保存すると、再読込後も同じ専門と勤務時間であること' do
          keeper = described_class.new(name: '田中', specialties: [TaxonClass.mammal, TaxonClass.bird]).clock_in(200)
          keeper.save!
          restored = described_class.find(keeper.id)
          expect(restored.specialties).to eq([TaxonClass.mammal, TaxonClass.bird])
          expect(restored.worked_minutes).to eq(200)
        end

        it '生成直後の勤務時間は0分であること' do
          expect(described_class.new(name: '田中', specialties: [TaxonClass.mammal]).worked_minutes).to eq(0)
        end
      end

      it '#to_s は 飼育員 名前(専門担当) の形で表されること' do
        expect(mammal_keeper.to_s).to start_with('飼育員 田中(')
        expect(mammal_keeper.to_s).to end_with('担当)')
      end
    end

    RSpec.describe Veterinarian do
      let(:vet) { described_class.new(name: '佐藤') }

      it 'job_title は「獣医」であること' do
        expect(vet.job_title).to eq('獣医')
      end

      it '#to_s は 獣医 名前 の形で表されること' do
        expect(vet.to_s).to eq('獣医 佐藤')
      end
    end

    RSpec.describe '病気の進行' do
      let(:animal) { build_adult(SpeciesCatalog.lion, max_health: 30) }

      it '治療しないと病気で衰弱し、やがて死亡すること' do
        animal.fall_ill(IllnessCatalog.pneumonia)
        animal.grow_older(5)
        expect(animal).to be_dead
        expect(animal.cause_of_death).to eq(:illness)
      end
    end
  end
end
