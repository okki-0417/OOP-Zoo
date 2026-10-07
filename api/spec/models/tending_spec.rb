# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tending do
  subject(:tending) { described_class.new(keeper:, enclosure:, occupancy: Occupancy.new(enclosure:, occupants:)) }

  let(:keeper) { build(:keeper, name: '田中') }
  let(:enclosure) { build(:enclosure, name: 'サバンナ') }
  let(:occupants) { [] }
  let(:lion) { build(:animal) }
  let(:penguin) { build(:animal, species: SpeciesCatalog.emperor_penguin) }

  describe '.new' do
    it 'frozen であること' do
      expect(tending).to be_frozen
    end
  end

  describe '#violation!' do
    context '空のエリアで、田中が未担当のとき' do
      it '例外を投げないこと' do
        expect { tending.violation! }.not_to raise_error
      end
    end

    context '哺乳類専門の田中のエリアに、哺乳類のライオンだけがいるとき' do
      let(:occupants) { [lion] }

      it '例外を投げないこと' do
        expect { tending.violation! }.not_to raise_error
      end
    end

    context '哺乳類専門の田中のエリアに、鳥類のペンギンが混ざっているとき' do
      let(:occupants) { [lion, penguin] }

      it '田中・サバンナ・鳥類を含む AssignmentNotAllowed を投げること' do
        expect { tending.violation! }.to raise_error(Errors::AssignmentNotAllowed, /田中.*サバンナ.*鳥類/)
      end
    end

    context '田中がすでにサバンナを担当しているとき' do
      before { keeper.enclosures << enclosure }

      it '二重配属として「田中はすでにサバンナを担当」の AssignmentNotAllowed を投げること' do
        expect { tending.violation! }.to raise_error(Errors::AssignmentNotAllowed, /田中.*すでに.*サバンナ/)
      end
    end

    context '別の飼育員の鈴木だけがサバンナを担当しているとき' do
      before { build(:keeper, name: '鈴木').enclosures << enclosure }

      it '例外を投げないこと' do
        expect { tending.violation! }.not_to raise_error
      end
    end
  end

  describe '#perform' do
    context '違反がないとき' do
      let(:occupants) { [lion] }

      it '田中がサバンナの担当になる(in_charge_of? が true)こと' do
        tending.perform

        expect(keeper.in_charge_of?(enclosure)).to be(true)
      end

      context '飼育員とエリアが保存済みのとき' do
        let(:keeper) { create(:keeper, name: '田中') }
        let(:enclosure) { create(:enclosure, name: 'サバンナ') }

        it 'assignments を 0 行から 1 行に増やすこと' do
          expect { tending.perform }.to change(Assignment, :count).from(0).to(1)
        end
      end
    end

    context '違反があるとき' do
      let(:occupants) { [penguin] }

      it 'AssignmentNotAllowed を投げ、田中を担当にしないこと' do
        expect { tending.perform }.to raise_error(Errors::AssignmentNotAllowed)
        expect(keeper.in_charge_of?(enclosure)).to be(false)
      end
    end
  end

  describe '#to_s' do
    it '"田中をサバンナに配属" を返すこと' do
      expect(tending.to_s).to eq('田中をサバンナに配属')
    end
  end
end
