# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::HireVeterinarian do
  describe 'hireVeterinarian(name:)' do
    subject(:response) { OopZooSchema.execute('mutation { hireVeterinarian(name: "山田") { name } }', context: { current_zoo: zoo }).to_h }

    let!(:zoo) { create(:zoo) }

    it '山田を返すこと' do
      expect(response).to eq('data' => { 'hireVeterinarian' => { 'name' => '山田' } })
    end

    it '山田をこの動物園の獣医として保存し、園の残高から契約金を引くこと' do
      response

      expect(zoo.veterinarians.sole.name).to eq('山田')
      expect(zoo.reload.balance.yen).to eq(100_000 - Veterinarian::SIGNING_FEE_YEN)
    end
  end
end
