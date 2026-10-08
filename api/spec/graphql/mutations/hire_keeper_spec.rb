# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::HireKeeper do
  describe 'hireKeeper(name:, specialties:)' do
    subject(:response) do
      OopZooSchema.execute('mutation { hireKeeper(name: "田中", specialties: ["mammal", "bird"]) { name specialties { code } } }').to_h
    end

    let!(:zoo) { create(:zoo) }

    it '哺乳類と鳥類を専門とする田中を返すこと' do
      expect(response).to eq(
        'data' => { 'hireKeeper' => { 'name' => '田中', 'specialties' => [{ 'code' => 'mammal' }, { 'code' => 'bird' }] } }
      )
    end

    it '田中を保存し、園の残高から契約金を引くこと' do
      response

      expect(Keeper.sole.name).to eq('田中')
      expect(zoo.reload.balance.yen).to eq(100_000 - Keeper::SIGNING_FEE_YEN)
    end
  end
end
