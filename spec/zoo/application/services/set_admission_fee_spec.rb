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
  let(:service) do
    described_class.new(command: commands::SetAdmissionFeeCommand.new(fee: 3_500).bind(zoo:, unit_of_work:))
  end

  describe '#call' do
    it 'fee=3500 で入園料を改定すると Zoo の admission_fee が更新され、result.value が ¥3,500 の Money になること' do
      result = service.call

      expect(zoo.load.admission_fee).to eq(shared::Money.yen(3_500))
      expect(result.value).to eq(shared::Money.yen(3_500))
    end
  end
end
