# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::DischargeKeeper do
  describe 'dischargeKeeper(enclosureId: "e1", keeperId: "k1")' do
    it 'enclosure_id: e1・keeper_id: k1 の DischargeKeeperCommand を Services::DischargeKeeper に渡すこと' do
      service = stub_service(:discharge_keeper, Services::Result.success(:discharge_keeper, Object.new))

      OopZooSchema.execute('mutation { dischargeKeeper(enclosureId: "e1", keeperId: "k1") { __typename } }')

      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::DischargeKeeperCommand).and(having_attributes(enclosure_id: 'e1', keeper_id: 'k1')))
    end
  end
end
