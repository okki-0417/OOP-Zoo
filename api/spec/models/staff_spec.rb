# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Keeper do
  subject(:keeper) { described_class.new(name:, specialties:) }

  let(:name) { '田中' }
  let(:specialties) { [TaxonClass.mammal] }

  describe '#specialized_in?' do
    it '哺乳類専門の飼育員はライオンの綱に true・コウテイペンギンの綱に false を返すこと' do
      expect(keeper.specialized_in?(build(:animal).taxon_class)).to be(true)
      expect(keeper.specialized_in?(build(:animal, species: SpeciesCatalog.emperor_penguin).taxon_class)).to be(false)
    end
  end

  describe '#job_title' do
    it '"飼育員" を返すこと' do
      expect(keeper.job_title).to eq('飼育員')
    end
  end

  describe '#valid?' do
    context '専門分野が空のとき' do
      let(:specialties) { [] }

      it 'false を返し、specialties に「専門分野を1つ以上指定してください」が付くこと' do
        expect(keeper).not_to be_valid
        expect(keeper.errors[:specialties]).to eq(['専門分野を1つ以上指定してください'])
      end
    end

    context '名前が空文字のとき' do
      let(:name) { '' }

      it 'false を返すこと' do
        expect(keeper).not_to be_valid
      end
    end
  end

  describe '#worked_minutes' do
    it '生成直後は 0 を返すこと' do
      expect(keeper.worked_minutes).to eq(0)
    end
  end

  describe '#clock_in' do
    context '勤務0分のとき' do
      it 'clock_in(100) は self を返し、worked_minutes=100・remaining_minutes=380 になること' do
        expect(keeper.clock_in(100)).to be(keeper)
        expect(keeper).to have_attributes(worked_minutes: 100, remaining_minutes: 380)
      end
    end

    context '勤務460分で残り20分のとき' do
      before { keeper.clock_in(460) }

      it 'clock_in(30) は WorkNotAllowed(残り20分) を投げ、worked_minutes は 460 のままであること' do
        expect { keeper.clock_in(30) }
          .to raise_error(Errors::WorkNotAllowed, '飼育員田中は今日の勤務時間が足りません(残り20分)')
        expect(keeper.worked_minutes).to eq(460)
      end
    end
  end

  describe '#available_for?' do
    context '勤務460分で残り20分のとき' do
      before { keeper.clock_in(460) }

      it 'available_for?(20) は true・available_for?(21) は false を返すこと' do
        expect(keeper.available_for?(20)).to be(true)
        expect(keeper.available_for?(21)).to be(false)
      end
    end
  end

  describe '#end_shift' do
    context '勤務460分のとき' do
      before { keeper.clock_in(460) }

      it 'remaining_minutes が 480 に戻ること' do
        expect(keeper.end_shift.remaining_minutes).to eq(480)
      end
    end
  end

  describe '#save!' do
    let(:specialties) { [TaxonClass.mammal, TaxonClass.bird] }

    before { keeper.clock_in(200).save! }

    it '専門[哺乳類・鳥類]・勤務200分が、再読込後も同じであること' do
      restored = described_class.find(keeper.id)
      expect(restored.specialties).to eq([TaxonClass.mammal, TaxonClass.bird])
      expect(restored.worked_minutes).to eq(200)
    end
  end

  describe '#to_s' do
    it '"飼育員 田中(" で始まり "担当)" で終わること' do
      expect(keeper.to_s).to start_with('飼育員 田中(').and end_with('担当)')
    end
  end
end

RSpec.describe Veterinarian do
  subject(:vet) { described_class.new(name: '佐藤') }

  describe '#job_title' do
    it '"獣医" を返すこと' do
      expect(vet.job_title).to eq('獣医')
    end
  end

  describe '#to_s' do
    it '"獣医 佐藤" を返すこと' do
      expect(vet.to_s).to eq('獣医 佐藤')
    end
  end
end

RSpec.describe Animal do
  subject(:animal) { build(:animal, max_health: 30) }

  describe '#grow_older' do
    context '体力30で肺炎にかかっているとき' do
      before { animal.fall_ill(IllnessCatalog.pneumonia) }

      it '5日経つと病気で死亡し、cause_of_death が :illness になること' do
        animal.grow_older(5)

        expect(animal).to be_dead
        expect(animal.cause_of_death).to eq(:illness)
      end
    end
  end
end
