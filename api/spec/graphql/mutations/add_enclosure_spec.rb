# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::AddEnclosure do
  describe 'addEnclosure(name: "丘", celsius: 28, capacity: 4)' do
    it 'name: 丘・celsius: 28・capacity: 4・climate_controlled: false の AddEnclosureCommand を Services::AddEnclosure に渡すこと' do
      service = stub_service(:add_enclosure, Services::Result.success(:add_enclosure, Object.new))

      OopZooSchema.execute('mutation { addEnclosure(name: "丘", celsius: 28, capacity: 4) { __typename } }')

      expect(service).to have_received(:new).with(
        command: an_instance_of(Services::Commands::AddEnclosureCommand)
                 .and(having_attributes(name: '丘', celsius: 28, capacity: 4, climate_controlled: false))
      )
    end
  end

  describe 'addEnclosure(name: "温室", celsius: 30, capacity: 2, climateControlled: true)' do
    it 'name: 温室・celsius: 30・capacity: 2・climate_controlled: true の AddEnclosureCommand を Services::AddEnclosure に渡すこと' do
      service = stub_service(:add_enclosure, Services::Result.success(:add_enclosure, Object.new))

      OopZooSchema.execute('mutation { addEnclosure(name: "温室", celsius: 30, capacity: 2, climateControlled: true) { __typename } }')

      expect(service).to have_received(:new).with(
        command: an_instance_of(Services::Commands::AddEnclosureCommand)
                 .and(having_attributes(name: '温室', celsius: 30, capacity: 2, climate_controlled: true))
      )
    end
  end
end
