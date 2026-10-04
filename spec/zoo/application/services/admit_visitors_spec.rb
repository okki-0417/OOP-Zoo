# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AdmitVisitors do
  shared    = Zoo::Domain::Shared
  in_memory = Zoo::Infrastructure::InMemory

  let(:zoo) do
    in_memory::InMemoryZooRepository.new(
      Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: shared::Money.yen(2000))
    )
  end
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new }

  def admit(count)
    command = Zoo::Application::Commands::AdmitVisitorsCommand.new(count:)
    described_class.new(command: command.bind(zoo:, unit_of_work:)).call
  end

  describe '#call' do
    it '入園料2000円で count 500 を受け入れると value の revenue が 1,000,000円になること' do
      expect(admit(500).value).to eq(shared::Money.yen(1_000_000))
    end

    it '負の count -1 を渡すと ArgumentError が発生すること(ドメインの不変条件)' do
      expect { admit(-1) }.to raise_error(ArgumentError)
    end
  end
end
