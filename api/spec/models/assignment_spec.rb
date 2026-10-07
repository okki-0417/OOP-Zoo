# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Assignment do
  let(:enclosure) do
    create(:enclosure, name: 'サバンナ')
  end
  let(:tanaka) { create(:keeper, name: '田中') }

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
