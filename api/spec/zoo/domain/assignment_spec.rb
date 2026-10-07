# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Assignment do
      let(:enclosure) do
        Enclosure.create!(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end
      let(:tanaka) { Keeper.create!(name: '田中', specialties: [TaxonClass.mammal]) }

      it '田中をサバンナに割り当てて保存すると、田中の enclosures と サバンナの keepers から互いに引けること' do
        described_class.create!(keeper: tanaka, enclosure:)

        expect(tanaka.reload.enclosures).to eq([enclosure])
        expect(enclosure.reload.keepers).to eq([tanaka])
      end

      it '同じ飼育員とエリアの組を二重に保存すると一意制約違反になること' do
        described_class.create!(keeper: tanaka, enclosure:)

        expect { described_class.create!(keeper: tanaka, enclosure:) }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end
end
