# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe EnclosureAssignment do
      let(:keeper) { Keeper.new(name: '田中', specialties: [TaxonClass.mammal]) }
      let(:enclosure) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end
      let(:lion) { build_adult(SpeciesCatalog.lion) }
      let(:penguin) { build_adult(SpeciesCatalog.emperor_penguin) }

      describe '#keeper_id / #enclosure_id' do
        it '保持する keeper / enclosure の id を返すこと' do
          assignment = described_class.new(keeper: keeper, enclosure: enclosure)
          expect(assignment.keeper_id).to eq(keeper.id)
          expect(assignment.enclosure_id).to eq(enclosure.id)
        end
      end

      describe '#assignment_violation!' do
        it 'occupants 未指定なら専門に関わらず例外を出さないこと' do
          assignment = described_class.new(keeper: keeper, enclosure: enclosure)
          expect { assignment.assignment_violation! }.not_to raise_error
        end

        it '専門外の綱が混ざると EnclosureAssignmentNotAllowed を綱ラベル付きで出すこと' do
          assignment = described_class.new(keeper: keeper, enclosure: enclosure, occupants: [lion, penguin])
          expect { assignment.assignment_violation! }
            .to raise_error(Errors::EnclosureAssignmentNotAllowed, /田中.*サバンナ.*鳥類/)
        end

        it '専門の綱だけなら例外を出さないこと' do
          assignment = described_class.new(keeper: keeper, enclosure: enclosure, occupants: [lion])
          expect { assignment.assignment_violation! }.not_to raise_error
        end
      end

      describe '同一性と不変性' do
        it '同じ id の EnclosureAssignment は等価で hash が一致すること' do
          id = Shared::Identifier.new
          a = described_class.new(keeper: keeper, enclosure: enclosure, id: id)
          b = described_class.new(keeper: keeper, enclosure: enclosure, id: id)
          expect(a).to eq(b)
          expect(a.hash).to eq(b.hash)
        end

        it '生成後は frozen であること' do
          expect(described_class.new(keeper: keeper, enclosure: enclosure)).to be_frozen
        end
      end

      describe '#to_s' do
        it '名前を配属 の形で表されること' do
          assignment = described_class.new(keeper: keeper, enclosure: enclosure)
          expect(assignment.to_s).to eq('田中をサバンナに配属')
        end
      end
    end
  end
end
