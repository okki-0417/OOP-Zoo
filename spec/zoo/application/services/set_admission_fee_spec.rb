# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::SetAdmissionFee do
  shared    = Zoo::Domain::Shared
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:zoo) do
    in_memory::InMemoryZooRepository.new(
      Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: shared::Money.yen(2_000))
    )
  end
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }
  let(:service) { described_class.new(zoo: zoo, unit_of_work: unit_of_work) }

  describe '#call' do
    it '入園料を改定すると Zoo の admission_fee が更新されること' do
      service.call(commands::SetAdmissionFeeCommand.new(fee: shared::Money.yen(3_500)))

      expect(zoo.load.admission_fee).to eq(shared::Money.yen(3_500))
    end
  end
end
