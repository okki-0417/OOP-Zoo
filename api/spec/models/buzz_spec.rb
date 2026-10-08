# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Buzz do
  subject(:buzz) { described_class.new(animal:, today:) }

  let(:species) { SpeciesCatalog.grevys_zebra }
  let(:today) { 10 }
  let(:animal) { build(:animal, species:) }

  context '園で生まれていない、導入記録もない動物のとき' do
    describe '#kind' do
      it 'nil を返すこと' do
        expect(buzz.kind).to be_nil
      end
    end

    describe '#amount' do
      it '0.0 を返すこと' do
        expect(buzz.amount).to eq(0.0)
      end
    end
  end

  context '園で生まれた人気度60のグレビーシマウマのとき' do
    let(:animal) { build(:animal, species:, dam: build(:animal, :female, species:), age_in_days:) }

    context '生後0日のとき' do
      let(:age_in_days) { 0 }

      describe '#kind' do
        it ':newborn を返すこと' do
          expect(buzz.kind).to eq(:newborn)
        end
      end

      describe '#amount' do
        it '60 × 0.5 = 30.0 を返すこと' do
          expect(buzz.amount).to eq(30.0)
        end
      end
    end

    context '生後15日のとき' do
      let(:age_in_days) { 15 }

      describe '#amount' do
        it '30.0 の半分の 15.0 を返すこと' do
          expect(buzz.amount).to eq(15.0)
        end
      end
    end

    context '生後30日のとき' do
      let(:age_in_days) { 30 }

      describe '#kind' do
        it 'nil を返すこと' do
          expect(buzz.kind).to be_nil
        end
      end

      describe '#amount' do
        it '0.0 を返すこと' do
          expect(buzz.amount).to eq(0.0)
        end
      end
    end
  end

  context '10日目に導入した人気度60のグレビーシマウマのとき' do
    let(:animal) { build(:animal, species:, acquiring: Acquiring.new(day: 10)) }

    context '今日が10日目のとき' do
      describe '#kind' do
        it ':newcomer を返すこと' do
          expect(buzz.kind).to eq(:newcomer)
        end
      end

      describe '#amount' do
        it '60 × 0.25 = 15.0 を返すこと' do
          expect(buzz.amount).to eq(15.0)
        end
      end
    end

    context '今日が13日目のとき' do
      let(:today) { 13 }

      describe '#amount' do
        it '15.0 × (1 - 3/7) を返すこと' do
          expect(buzz.amount).to be_within(0.001).of(15.0 * 4 / 7)
        end
      end
    end

    context '今日が17日目のとき' do
      let(:today) { 17 }

      describe '#kind' do
        it 'nil を返すこと' do
          expect(buzz.kind).to be_nil
        end
      end

      describe '#amount' do
        it '0.0 を返すこと' do
          expect(buzz.amount).to eq(0.0)
        end
      end
    end
  end
end
