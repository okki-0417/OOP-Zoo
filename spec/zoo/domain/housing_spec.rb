# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Housing do
      let(:lion) { build_adult(SpeciesCatalog.lion, name: 'レオ') }
      let(:savanna) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end

      describe '.new' do
        it '個体と区画から入居イベントを作り、区画 id を導出すること' do
          event = described_class.new(animal: lion, enclosure: savanna, occurred_on: 3)
          expect(event.animal).to eq(lion)
          expect(event.enclosure).to eq(savanna)
          expect(event.enclosure_id).to eq(savanna.id)
          expect(event.occurred_on).to eq(3)
        end
      end

      it 'イミュータブルであること' do
        expect(described_class.new(animal: lion, enclosure: savanna)).to be_frozen
      end

      it '#to_s が収容を表すこと' do
        expect(described_class.new(animal: lion, enclosure: savanna).to_s).to eq('レオを収容')
      end

      describe '#admission_violation!' do
        let(:zebra) { build_adult(SpeciesCatalog.grevys_zebra) }

        def candidate(animal, enclosure, occupants = [])
          occupancy = Occupancy.new(enclosure, occupants)
          described_class.new(animal: animal, enclosure: enclosure, occupancy: occupancy)
        end

        it '違反がなければ例外を投げないこと' do
          expect { candidate(lion, savanna).admission_violation! }.not_to raise_error
        end

        it '死亡個体は HousingNotAllowed(死亡) であること' do
          dead = build_adult(SpeciesCatalog.lion).tap(&:die)
          expect { candidate(dead, savanna).admission_violation! }
            .to raise_error(Errors::HousingNotAllowed, /死亡/)
        end

        it '満員だと HousingNotAllowed(定員) であること' do
          full = Enclosure.new(name: '小屋', temperature: Shared::Temperature.celsius(28), capacity: 1)
          expect { candidate(lion, full, [build_adult(SpeciesCatalog.lion, name: '先住')]).admission_violation! }
            .to raise_error(Errors::HousingNotAllowed, /定員/)
        end

        it '適温に合わない個体は HousingNotAllowed(適応) であること' do
          cold = Enclosure.new(name: '極地', temperature: Shared::Temperature.celsius(-10), capacity: 4)
          expect { candidate(zebra, cold).admission_violation! }
            .to raise_error(Errors::HousingNotAllowed, /適応/)
        end

        it '同居できない種は HousingNotAllowed(捕食) であること' do
          expect { candidate(lion, savanna, [zebra]).admission_violation! }
            .to raise_error(Errors::HousingNotAllowed, /捕食/)
        end

        it '複数の違反を一度にまとめて報告すること' do
          full = Enclosure.new(name: '小屋', temperature: Shared::Temperature.celsius(28), capacity: 1)
          dead = build_adult(SpeciesCatalog.lion).tap(&:die)
          expect { candidate(dead, full, [build_adult(SpeciesCatalog.lion, name: '先住')]).admission_violation! }
            .to raise_error(Errors::HousingNotAllowed, /死亡.*定員/)
        end
      end
    end

    RSpec.describe Release do
      let(:lion) { build_adult(SpeciesCatalog.lion, name: 'レオ') }
      let(:savanna) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end
      let(:housing) { Housing.new(animal: lion, enclosure: savanna) }

      describe '.of' do
        it '閉じる入居イベントを持ち、個体はそこから導出されること' do
          event = described_class.of(housing, occurred_on: 5)
          expect(event.housing).to eq(housing)
          expect(event.animal).to eq(lion)
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
