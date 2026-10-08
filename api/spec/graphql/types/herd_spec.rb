# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Herd do
  let(:herd) do
    Herd.new(enclosure: build(:enclosure), species: SpeciesCatalog.grevys_zebra, size: 3, crowded: false)
  end

  describe 'multiplier' do
    it 'グレビーシマウマ3頭の 1.375 を小数第2位に丸めて 1.38 を返すこと' do
      expect(run_graphql_field('Herd.multiplier', herd)).to eq(1.38)
    end
  end

  describe 'bonus' do
    it '60 × 0.375 = 22.5 を丸めて 23 を返すこと' do
      expect(run_graphql_field('Herd.bonus', herd)).to eq(23)
    end
  end

  describe 'crowded' do
    it 'false を返すこと' do
      expect(run_graphql_field('Herd.crowded', herd)).to be(false)
    end
  end
end
