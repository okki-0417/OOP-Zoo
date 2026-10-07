# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::SetAdmissionFee do
  describe 'setAdmissionFee(fee: 1800)' do
    it 'fee: 1800 の SetAdmissionFeeCommand を Services::SetAdmissionFee に渡すこと' do
      service = stub_service(:set_admission_fee, Services::Result.success(:set_admission_fee, Object.new))

      OopZooSchema.execute('mutation { setAdmissionFee(fee: 1800) { __typename } }')

      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::SetAdmissionFeeCommand).and(having_attributes(fee: 1800)))
    end
  end
end
