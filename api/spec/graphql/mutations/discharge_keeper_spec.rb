# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DischargeKeeper do
  describe 'dischargeKeeper(enclosureId:, keeperId:)' do
    subject(:response) do
      OopZooSchema.execute(%(mutation { dischargeKeeper(enclosureId: "#{hill.id}", keeperId: "#{keeper.id}") { name } }),
                           context: { current_zoo: zoo }).to_h
    end

    let(:zoo) { create(:zoo) }
    let(:hill) { create(:enclosure, zoo:, name: '丘') }
    let(:keeper) { create(:keeper, zoo:, enclosures: [hill]) }

    it '丘を返すこと' do
      expect(response).to eq('data' => { 'dischargeKeeper' => { 'name' => '丘' } })
    end

    it '飼育員を丘の担当から外すこと' do
      response

      expect(keeper.reload.enclosures).to be_empty
    end
  end
end
