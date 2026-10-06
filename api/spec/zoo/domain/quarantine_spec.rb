# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Quarantine do
      let(:lion) { SpeciesCatalog.lion }

      it '.begin は観察日数0で始まること' do
        expect(described_class.begin.days_observed).to eq(0)
      end

      it '負の観察日数はエラーになること' do
        expect { described_class.new(-1) }.to raise_error(ArgumentError)
      end

      describe '#observe' do
        it '観察日数を加算した新しいインスタンスを返すこと(不変)' do
          q = described_class.new(5)
          advanced = q.observe(3)
          expect(advanced.days_observed).to eq(8)
          expect(q.days_observed).to eq(5)
        end

        it '0以下の日数はエラーになること' do
          expect { described_class.begin.observe(0) }.to raise_error(ArgumentError)
        end
      end

      describe '#days_remaining' do
        it '規定日数を超えても0未満にはならないこと' do
          expect(described_class.new(40).days_remaining).to eq(0)
        end
      end

      describe '#period_complete?' do
        it '規定日数ちょうど(30)で完了とみなすこと' do
          expect(described_class.new(30).period_complete?).to be(true)
          expect(described_class.new(29).period_complete?).to be(false)
        end
      end

      it '同じ観察日数どうしは等価であること' do
        expect(described_class.new(7)).to eq(described_class.new(7))
      end
    end
  end
end
