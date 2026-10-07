# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Enclosure do
  let(:hill) { create(:enclosure, name: 'ライオンの丘') }

  describe 'celsius' do
    it '28℃のエリアで 28.0 を返すこと' do
      expect(run_graphql_field('Enclosure.celsius', hill)).to eq(28.0)
    end
  end

  describe 'enrichment' do
    it '刺激度100のエリアで 100 を返すこと' do
      expect(run_graphql_field('Enclosure.enrichment', hill)).to eq(100)
    end
  end

  describe 'occupants' do
    let!(:leo) { create(:animal, name: 'レオ', enclosure: hill) }

    context '死亡したナラも収容されているとき' do
      before { create(:animal, :female, name: 'ナラ', enclosure: hill).die.save! }

      it '生きているレオだけを返すこと' do
        expect(run_graphql_field('Enclosure.occupants', hill.reload)).to eq([leo])
      end
    end
  end

  describe 'keepers' do
    let(:keeper) { create(:keeper) }

    before { keeper.enclosures << hill }

    it '担当の飼育員を返すこと' do
      expect(run_graphql_field('Enclosure.keepers', hill)).to eq([keeper])
    end
  end

  describe 'occupancy' do
    before { create(:animal, enclosure: hill) }

    it '定員4に1頭の Occupancy(full?=false)を返すこと' do
      expect(run_graphql_field('Enclosure.occupancy', hill)).to have_attributes(class: Occupancy, full?: false)
    end
  end
end
