# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::SetAdmissionFee do
  describe 'setAdmissionFee(fee:)' do
    subject(:response) { OopZooSchema.execute('mutation { setAdmissionFee(fee: 1800) { admissionFee } }').to_h }

    let!(:zoo) { create(:zoo) }

    it 'admissionFee=1800 の園を返すこと' do
      expect(response).to eq('data' => { 'setAdmissionFee' => { 'admissionFee' => 1800 } })
    end

    it '園の入園料を ¥1,800 にして保存すること' do
      response

      expect(zoo.reload.admission_fee).to eq(Money.yen(1_800))
    end
  end
end
