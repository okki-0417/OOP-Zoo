# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AddEnclosure do
  describe 'addEnclosure(name:, celsius:, capacity:, climateControlled:)' do
    subject(:response) do
      OopZooSchema.execute(
        'mutation { addEnclosure(name: "温室", celsius: 30, capacity: 2, climateControlled: true) { name capacity climateControlled } }'
      ).to_h
    end

    let!(:zoo) { create(:zoo) }

    it '定員2・空調付きの温室を返すこと' do
      expect(response).to eq(
        'data' => { 'addEnclosure' => { 'name' => '温室', 'capacity' => 2, 'climateControlled' => true } }
      )
    end

    it '温室を保存し、園の残高から建設費を引くこと' do
      response

      expect(Enclosure.sole.name).to eq('温室')
      expect(zoo.reload.balance.yen).to eq(
        100_000 - Enclosure.construction_cost(capacity: 2, climate_controlled: true).yen
      )
    end
  end
end
