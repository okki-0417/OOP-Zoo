# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::MakeRounds do
  describe 'makeRounds(keeperId: "k1")' do
    it 'keeper_id: k1 の MakeRoundsCommand を Services::MakeRounds に渡すこと' do
      service = stub_service(:make_rounds, Services::Result.success(:make_rounds, Object.new))

      OopZooSchema.execute('mutation { makeRounds(keeperId: "k1") { __typename } }')

      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::MakeRoundsCommand).and(having_attributes(keeper_id: 'k1')))
    end
  end
end
