# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::OperateDay do
  describe 'operateDay' do
    it 'OperateDayCommand を Services::OperateDay に渡すこと' do
      service = stub_service(:operate_day, Services::Result.success(:operate_day, Object.new))

      OopZooSchema.execute('mutation { operateDay { __typename } }')

      expect(service).to have_received(:new)
        .with(command: an_instance_of(Services::Commands::OperateDayCommand))
    end
  end
end
