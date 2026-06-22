# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Assignment do
      let(:enclosure) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end
      let(:tanaka) { Keeper.new(name: '田中', specialties: [TaxonClass.mammal]) }
      let(:suzuki) { Keeper.new(name: '鈴木', specialties: [TaxonClass.mammal]) }

      it 'エリアと現担当陣を保持すること' do
        assignment = described_class.new(enclosure, [tanaka, suzuki])
        expect(assignment.enclosure).to eq(enclosure)
        expect(assignment.assignees).to contain_exactly(tanaka, suzuki)
      end

      it '担当陣を省略すると空であること' do
        expect(described_class.new(enclosure).assignees).to be_empty
      end
    end
  end
end
