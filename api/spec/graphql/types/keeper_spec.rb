# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Keeper do
  let(:keeper) { create(:keeper, name: '田中', specialties: [TaxonClass.bird]) }

  describe 'name' do
    it '"田中" を返すこと' do
      expect(run_graphql_field('Keeper.name', keeper)).to eq('田中')
    end
  end

  describe 'specialties' do
    it '[鳥類] を返すこと' do
      expect(run_graphql_field('Keeper.specialties', keeper)).to eq([TaxonClass.bird])
    end
  end

  describe 'remainingMinutes' do
    it 'まだ働いていない飼育員で 480 を返すこと' do
      expect(run_graphql_field('Keeper.remainingMinutes', keeper)).to eq(480)
    end
  end

  describe 'enclosures' do
    let(:pond) { create(:enclosure, name: '池') }

    before { keeper.enclosures << pond }

    it '担当するエリア [池] を返すこと' do
      expect(run_graphql_field('Keeper.enclosures', keeper)).to eq([pond])
    end
  end
end
