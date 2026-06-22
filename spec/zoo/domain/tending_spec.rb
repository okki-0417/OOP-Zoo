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

      def occupancy(*occupants)
        Occupancy.new(enclosure, occupants)
      end

      def roster(*assignees)
        Assignment.new(enclosure, assignees)
      end

      describe '#keeper_id / #enclosure_id' do
        it '保持する keeper / enclosure の id を返すこと' do
          tending = described_class.new(keeper: keeper, enclosure: enclosure)
          expect(tending.keeper_id).to eq(keeper.id)
          expect(tending.enclosure_id).to eq(enclosure.id)
        end
      end

      describe '#violation!' do
        it 'occupancy / assignment 未指定なら例外を出さないこと' do
          tending = described_class.new(keeper: keeper, enclosure: enclosure)
          expect { tending.violation! }.not_to raise_error
        end

        it '専門外の綱が混ざると AssignmentNotAllowed を綱ラベル付きで出すこと' do
          tending = described_class.new(keeper: keeper, enclosure: enclosure, occupancy: occupancy(lion, penguin))
          expect { tending.violation! }
            .to raise_error(Errors::AssignmentNotAllowed, /田中.*サバンナ.*鳥類/)
        end

        it '専門の綱だけなら例外を出さないこと' do
          tending = described_class.new(keeper: keeper, enclosure: enclosure, occupancy: occupancy(lion))
          expect { tending.violation! }.not_to raise_error
        end

        it 'assignment に同一 id の飼育員がいれば二重配属として AssignmentNotAllowed を出すこと' do
          tending = described_class.new(keeper: keeper, enclosure: enclosure, assignment: roster(keeper))
          expect { tending.violation! }
            .to raise_error(Errors::AssignmentNotAllowed, /田中.*すでに.*サバンナ/)
        end

        it 'assignment が他の飼育員だけなら例外を出さないこと' do
          other = Keeper.new(name: '鈴木', specialties: [TaxonClass.mammal])
          tending = described_class.new(keeper: keeper, enclosure: enclosure, assignment: roster(other))
          expect { tending.violation! }.not_to raise_error
        end
      end

      describe '同一性と不変性' do
        it '同じ id の Tending は等価で hash が一致すること' do
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
          tending = described_class.new(keeper: keeper, enclosure: enclosure)
          expect(tending.to_s).to eq('田中をサバンナに配属')
        end
      end
    end
  end
end
