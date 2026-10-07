# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::AssignKeeper do
  describe 'assignKeeper(enclosureId: "e1", keeperId: "k1")' do
    it 'enclosure_id: e1・keeper_id: k1 の AssignKeeperCommand を Services::AssignKeeper に渡すこと' do
      service = stub_service(:assign_keeper, Services::Result.success(:assign_keeper, Object.new))

      OopZooSchema.execute('mutation { assignKeeper(enclosureId: "e1", keeperId: "k1") { __typename } }')

      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::AssignKeeperCommand).and(having_attributes(enclosure_id: 'e1', keeper_id: 'k1')))
    end
  end
end
