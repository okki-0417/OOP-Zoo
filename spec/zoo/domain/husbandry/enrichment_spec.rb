# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    module Husbandry
      RSpec.describe Enrichment do
        it '.stimulating は満点(100)であること' do
          expect(described_class.stimulating.level).to eq(100)
        end

        it '整数以外はエラーになること' do
          expect { described_class.new(1.5) }.to raise_error(ArgumentError)
        end

        it '0未満・100超はクランプされること' do
          expect(described_class.new(-10).level).to eq(0)
          expect(described_class.new(150).level).to eq(100)
        end

        describe '#depleted_by / #enriched_by' do
          it '減衰・補充で値が増減すること' do
            expect(described_class.new(50).depleted_by(20).level).to eq(30)
            expect(described_class.new(50).enriched_by(20).level).to eq(70)
          end

          it '負の量はエラーになること' do
            expect { described_class.new(50).depleted_by(-1) }.to raise_error(ArgumentError)
            expect { described_class.new(50).enriched_by(-1) }.to raise_error(ArgumentError)
          end
        end

        describe '#barren?' do
          it 'しきい値(30)以下で殺風景とみなすこと' do
            expect(described_class.new(30).barren?).to be(true)
            expect(described_class.new(31).barren?).to be(false)
          end
        end

        it '同じ値どうしは等価であること' do
          expect(described_class.new(40)).to eq(described_class.new(40))
        end
      end
    end
  end
end
