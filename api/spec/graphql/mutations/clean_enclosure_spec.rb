# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::CleanEnclosure do
  describe 'cleanEnclosure(enclosureId: "e1", keeperId: "k1")' do
    it 'enclosure_id: e1・keeper_id: k1 の CleanEnclosureCommand を Services::CleanEnclosure に渡すこと' do
      service = stub_service(:clean_enclosure, Services::Result.success(:clean_enclosure, Object.new))

      OopZooSchema.execute('mutation { cleanEnclosure(enclosureId: "e1", keeperId: "k1") { __typename } }')

      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::CleanEnclosureCommand).and(having_attributes(enclosure_id: 'e1', keeper_id: 'k1')))
    end
  end
end
