# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Assignment do
  subject(:assign) { described_class.create!(keeper: tanaka, enclosure:) }

  let(:enclosure) { create(:enclosure, name: 'サバンナ') }
  let(:tanaka) { create(:keeper, name: '田中') }

  describe '.create!' do
    it '田中の enclosures と サバンナの keepers から互いに引けるようになること' do
      assign

      expect(tanaka.reload.enclosures).to eq([enclosure])
      expect(enclosure.reload.keepers).to eq([tanaka])
    end

    context '同じ田中とサバンナの組が保存済みのとき' do
      before { described_class.create!(keeper: tanaka, enclosure:) }

      it 'ActiveRecord::RecordNotUnique を投げること' do
        expect { assign }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end
end
