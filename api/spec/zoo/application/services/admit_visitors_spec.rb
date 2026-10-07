# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AdmitVisitors do
  shared = Zoo::Domain::Shared

  let!(:zoo) { create_zoo(admission_fee: 2_000) }

  def admit(count)
    described_class.new(command: Zoo::Application::Commands::AdmitVisitorsCommand.new(count:)).call
  end

  describe '#call' do
    it '入園料2000円で count 500 を受け入れると value の revenue が 1,000,000円になり、保存された来園者数が 500 になること' do
      expect(admit(500).value).to eq(shared::Money.yen(1_000_000))
      expect(zoo.reload.visitor_count).to eq(500)
    end

    it '負の count -1 を渡すと ArgumentError が発生すること(ドメインの不変条件)' do
      expect { admit(-1) }.to raise_error(ArgumentError)
    end
  end
end
