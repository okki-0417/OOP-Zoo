# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::RunDays do
  describe 'runDays(days: 7)' do
    it 'days: 7 の RunDaysCommand を Services::RunDays に渡すこと' do
      service = stub_service(:run_days, Services::Result.success(:run_days, Object.new))

      OopZooSchema.execute('mutation { runDays(days: 7) { __typename } }')

      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::RunDaysCommand).and(having_attributes(days: 7)))
    end
  end

  it "runDays(days: 0) は Command の ArgumentError で、サービスを呼ばずに message 'days は1以上でなければなりません'・extensions.code 'InvalidArgument' になること" do
    allow(Services::RunDays).to receive(:new)

    response = OopZooSchema.execute('mutation { runDays(days: 0) { days } }').to_h

    expect(Services::RunDays).not_to have_received(:new)
    expect(response['errors'].first).to include(
      'message' => 'days は1以上でなければなりません', 'extensions' => { 'code' => 'InvalidArgument' }
    )
  end
end
