# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AdmitVisitors do
  shared    = Zoo::Domain::Shared
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:zoo) do
    in_memory::InMemoryZooRepository.new(
      Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: shared::Money.yen(2000))
    )
  end
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }
  let(:service) { described_class.new(zoo: zoo, unit_of_work: unit_of_work) }

  describe '#call' do
    it '入園料2000円で500人を受け入れると revenue が 1,000,000円になること' do
      revenue = service.call(commands::AdmitVisitorsCommand.new(count: 500))

      expect(revenue).to eq(shared::Money.yen(1_000_000))
    end

    it '負の人数 -1 を渡すと ArgumentError が発生すること(ドメインの不変条件)' do
      expect { service.call(commands::AdmitVisitorsCommand.new(count: -1)) }.to raise_error(ArgumentError)
    end
  end
end
