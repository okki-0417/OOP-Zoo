# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Housing do
  subject(:housing) { described_class.new(animal:, enclosure:, occupancy:) }

  let(:animal) { build(:animal, name: 'レオ') }
  let(:enclosure) { build(:enclosure, name: 'サバンナ') }
  let(:occupants) { [] }
  let(:occupancy) { Occupancy.new(enclosure:, occupants:) }

  describe '.new' do
    it '渡した animal・enclosure を #animal・#enclosure で返すこと' do
      expect(housing).to have_attributes(animal:, enclosure:)
    end

    it 'frozen であること' do
      expect(housing).to be_frozen
    end

    context 'occupancy を省略したとき' do
      subject(:housing) { described_class.new(animal:, enclosure:) }

      let(:enclosure) { create(:enclosure, capacity: 1) }

      before { create(:animal, enclosure:) }

      it '保存済みの住人から占有を組み立て、定員1に先住がいるので #perform が HousingNotAllowed(定員) を投げること' do
        expect { housing.perform }.to raise_error(Errors::HousingNotAllowed, /定員/)
      end
    end
  end

  describe '#to_s' do
    it '"レオを収容" を返すこと' do
      expect(housing.to_s).to eq('レオを収容')
    end
  end

  describe '#perform' do
    context '収容の違反がないとき' do
      it 'レオの enclosure をサバンナにして保存すること' do
        housing.perform

        expect(animal.reload.enclosure).to eq(enclosure)
      end
    end

    context '収容の違反があるとき' do
      let(:animal) { build(:animal).die }

      it 'HousingNotAllowed を投げ、動物を保存せず enclosure も nil のままにすること' do
        expect { housing.perform }.to raise_error(Errors::HousingNotAllowed)
        expect(animal).to be_new_record
        expect(animal.enclosure).to be_nil
      end
    end
  end

  describe '#admission_violation!' do
    context '違反がないとき' do
      it '例外を投げないこと' do
        expect { housing.admission_violation! }.not_to raise_error
      end
    end

    context '動物が死亡しているとき' do
      let(:animal) { build(:animal).die }

      it 'HousingNotAllowed(死亡) を投げること' do
        expect { housing.admission_violation! }.to raise_error(Errors::HousingNotAllowed, /死亡/)
      end
    end

    context '定員1のエリアに先住がいるとき' do
      let(:enclosure) { build(:enclosure, capacity: 1) }
      let(:occupants) { [build(:animal)] }

      it 'HousingNotAllowed(定員) を投げること' do
        expect { housing.admission_violation! }.to raise_error(Errors::HousingNotAllowed, /定員/)
      end
    end

    context '-10℃のエリアにグレビーシマウマを入れるとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.grevys_zebra) }
      let(:enclosure) { build(:enclosure, celsius: -10) }

      it 'HousingNotAllowed(適応) を投げること' do
        expect { housing.admission_violation! }.to raise_error(Errors::HousingNotAllowed, /適応/)
      end
    end

    context 'グレビーシマウマのいるエリアにライオンを入れるとき' do
      let(:occupants) { [build(:animal, species: SpeciesCatalog.grevys_zebra)] }

      it 'HousingNotAllowed(捕食) を投げること' do
        expect { housing.admission_violation! }.to raise_error(Errors::HousingNotAllowed, /捕食/)
      end
    end

    context 'ホッキョクグマのいるエリアにホッキョクグマを入れるとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.polar_bear) }
      let(:enclosure) { build(:enclosure, celsius: -10) }
      let(:occupants) { [build(:animal, species: SpeciesCatalog.polar_bear)] }

      it 'HousingNotAllowed(単独性) を投げること' do
        expect { housing.admission_violation! }.to raise_error(Errors::HousingNotAllowed, /単独性/)
      end
    end

    context 'コウテイペンギンのいるエリアにガラパゴスゾウガメを入れるとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.galapagos_tortoise) }
      let(:occupants) { [build(:animal, species: SpeciesCatalog.emperor_penguin)] }

      it 'HousingNotAllowed(適温域) を投げること' do
        expect { housing.admission_violation! }.to raise_error(Errors::HousingNotAllowed, /適温域/)
      end
    end

    context '死亡した動物を、先住のいる定員1のエリアに入れるとき' do
      let(:animal) { build(:animal).die }
      let(:enclosure) { build(:enclosure, capacity: 1) }
      let(:occupants) { [build(:animal)] }

      it '死亡と定員の違反をまとめて1つの HousingNotAllowed で投げること' do
        expect { housing.admission_violation! }.to raise_error(Errors::HousingNotAllowed, /死亡.*定員/)
      end
    end
  end
end
