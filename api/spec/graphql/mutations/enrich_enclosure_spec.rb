# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::EnrichEnclosure do
  describe 'enrichEnclosure(enclosureId: "e1", keeperId: "k1")' do
    let!(:service) { stub_service(:enrich_enclosure, Services::Result.success(:enrich_enclosure, Object.new)) }

    before { OopZooSchema.execute('mutation { enrichEnclosure(enclosureId: "e1", keeperId: "k1") { __typename } }') }

    it 'enclosure_id: e1・keeper_id: k1 の EnrichEnclosureCommand を Services::EnrichEnclosure に渡すこと' do
      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::EnrichEnclosureCommand).and(having_attributes(enclosure_id: 'e1', keeper_id: 'k1')))
    end
  end
end
