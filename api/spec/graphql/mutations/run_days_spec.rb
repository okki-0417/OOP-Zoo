# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::RunDays do
  describe 'runDays(days: 7)' do
    let!(:service) { stub_service(:run_days, Services::Result.success(:run_days, Object.new)) }

    before { OopZooSchema.execute('mutation { runDays(days: 7) { __typename } }') }

    it 'days: 7 の RunDaysCommand を Services::RunDays に渡すこと' do
      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::RunDaysCommand).and(having_attributes(days: 7)))
    end
  end

  describe 'runDays(days: 0)' do
    subject(:response) { OopZooSchema.execute('mutation { runDays(days: 0) { days } }').to_h }

    before { allow(Services::RunDays).to receive(:new) }

    it 'Command の ArgumentError で、サービスを呼ばずに message "days は1以上でなければなりません"・extensions.code "InvalidArgument" にすること' do
      expect(response['errors'].first).to include(
        'message' => 'days は1以上でなければなりません', 'extensions' => { 'code' => 'InvalidArgument' }
      )
      expect(Services::RunDays).not_to have_received(:new)
    end
  end
end
