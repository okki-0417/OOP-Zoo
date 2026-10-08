# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::HireVeterinarian do
  describe 'hireVeterinarian(name:)' do
    subject(:response) { OopZooSchema.execute('mutation { hireVeterinarian(name: "山田") { name } }').to_h }

    let!(:zoo) { create(:zoo) }

    it '山田を返すこと' do
      expect(response).to eq('data' => { 'hireVeterinarian' => { 'name' => '山田' } })
    end

    it '山田を保存し、園の残高から契約金を引くこと' do
      response

      expect(Veterinarian.sole.name).to eq('山田')
      expect(zoo.reload.balance.yen).to eq(100_000 - Veterinarian::SIGNING_FEE_YEN)
    end
  end
end
