# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Housing do
      let(:lion) { build_adult(SpeciesCatalog.lion, name: 'レオ') }
      let(:savanna) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end

      describe '.record' do
        it '個体と区画から入居イベントを作ること' do
          event = described_class.record(animal: lion, enclosure: savanna, occurred_on: 3)
          expect(event.animal).to eq(lion)
          expect(event.enclosure_id).to eq(savanna.id)
          expect(event.occurred_on).to eq(3)
        end
      end

      it 'イミュータブルであること' do
        expect(described_class.record(animal: lion, enclosure: savanna)).to be_frozen
      end

      it '#to_s が収容を表すこと' do
        expect(described_class.record(animal: lion, enclosure: savanna).to_s).to eq('レオを収容')
      end
    end

    RSpec.describe Release do
      let(:lion) { build_adult(SpeciesCatalog.lion, name: 'レオ') }
      let(:savanna) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end
      let(:housing) { Housing.record(animal: lion, enclosure: savanna) }

      describe '.of' do
        it '閉じる入居イベントを持ち、個体と区画はそこから導出されること' do
          event = described_class.of(housing, occurred_on: 5)
          expect(event.housing).to eq(housing)
          expect(event.animal).to eq(lion)
          expect(event.enclosure_id).to eq(savanna.id)
          expect(event.occurred_on).to eq(5)
        end
      end

      it 'イミュータブルであること' do
        expect(described_class.of(housing)).to be_frozen
      end

      it '#to_s が解放を表すこと' do
        expect(described_class.of(housing).to_s).to eq('レオを解放')
      end
    end
  end
end
