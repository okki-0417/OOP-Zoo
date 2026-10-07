# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::SetAdmissionFee do
  let!(:zoo) { create(:zoo) }

  describe '#call' do
    it 'fee=3500 で入園料を改定すると保存された Zoo の admission_fee が更新され、result.value がその Zoo になること' do
      result = described_class.new(command: Services::Commands::SetAdmissionFeeCommand.new(fee: 3_500)).call

      expect(zoo.reload.admission_fee).to eq(Money.yen(3_500))
      expect(result.value.admission_fee).to eq(Money.yen(3_500))
    end
  end
end
