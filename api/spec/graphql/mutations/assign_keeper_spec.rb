# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AssignKeeper do
  describe 'assignKeeper(enclosureId:, keeperId:)' do
    subject(:response) do
      OopZooSchema.execute(%(mutation { assignKeeper(enclosureId: "#{hill.id}", keeperId: "#{keeper.id}") { name } }),
                           context: { current_zoo: zoo }).to_h
    end

    let(:zoo) { create(:zoo) }
    let(:hill) { create(:enclosure, zoo:, name: '丘') }
    let(:keeper) { create(:keeper, zoo:) }

    it '丘を返すこと' do
      expect(response).to eq('data' => { 'assignKeeper' => { 'name' => '丘' } })
    end

    it '飼育員を丘の担当にすること' do
      response

      expect(keeper.reload.enclosures).to eq([hill])
    end
  end
end
