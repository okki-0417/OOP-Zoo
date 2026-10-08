# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Buzz do
  let(:buzz) do
    Buzz.new(animal: build(:animal, species: SpeciesCatalog.grevys_zebra, acquiring: Acquiring.new(day: 10)), today: 13)
  end

  describe 'kind' do
    it '導入3日後のとき NEWCOMER を返すこと' do
      expect(Types::BuzzKind.coerce_isolated_result(run_graphql_field('Buzz.kind', buzz))).to eq('NEWCOMER')
    end
  end

  describe 'amount' do
    it '15.0 × 4/7 ≒ 8.57 を丸めて 9 を返すこと' do
      expect(run_graphql_field('Buzz.amount', buzz)).to eq(9)
    end
  end
end
