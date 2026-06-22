# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Tending do
      let(:keeper) { Keeper.new(name: '田中', specialties: [TaxonClass.mammal]) }
      let(:enclosure) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end
      let(:lion) { build_adult(SpeciesCatalog.lion) }
      let(:penguin) { build_adult(SpeciesCatalog.emperor_penguin) }

      describe '#violation!' do
        it 'occupants 未指定なら専門に関わらず例外を出さないこと' do
          tending = described_class.new(keeper: keeper, enclosure: enclosure)
          expect { tending.violation! }.not_to raise_error
        end

        it '専門外の綱が混ざると AssignmentNotAllowed を綱ラベル付きで出すこと' do
          tending = described_class.new(keeper: keeper, enclosure: enclosure, occupants: [lion, penguin])
          expect { tending.violation! }
            .to raise_error(Errors::AssignmentNotAllowed, /田中.*サバンナ.*鳥類/)
        end

        it '専門の綱だけなら例外を出さないこと' do
          tending = described_class.new(keeper: keeper, enclosure: enclosure, occupants: [lion])
          expect { tending.violation! }.not_to raise_error
        end

        it 'keepers に同一 id の飼育員がいれば二重配属として AssignmentNotAllowed を出すこと' do
          tending = described_class.new(keeper: keeper, enclosure: enclosure, keepers: [keeper])
          expect { tending.violation! }
            .to raise_error(Errors::AssignmentNotAllowed, /田中.*すでに.*サバンナ/)
        end

        it 'keepers が他の飼育員だけなら例外を出さないこと' do
          other = Keeper.new(name: '鈴木', specialties: [TaxonClass.mammal])
          tending = described_class.new(keeper: keeper, enclosure: enclosure, keepers: [other])
          expect { tending.violation! }.not_to raise_error
        end
      end

      describe '#assign' do
        it 'keeper と enclosure を保持した現役の Assignment を生むこと' do
          assignment = described_class.new(keeper: keeper, enclosure: enclosure).assign
          expect(assignment).to be_a(Assignment)
          expect(assignment.keeper_id).to eq(keeper.id)
          expect(assignment.enclosure_id).to eq(enclosure.id)
          expect(assignment).to be_active
        end
      end

      it '生成後は frozen であること' do
        expect(described_class.new(keeper: keeper, enclosure: enclosure)).to be_frozen
      end
    end
  end
end
