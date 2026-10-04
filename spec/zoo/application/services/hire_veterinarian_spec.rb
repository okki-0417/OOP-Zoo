# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::HireVeterinarian do
  domain    = Zoo::Domain
  money     = Zoo::Domain::Shared::Money
  balance   = Zoo::Domain::Shared::Balance
  commands  = Zoo::Application::Commands
  in_memory = Zoo::Infrastructure::InMemory

  let(:veterinarians) { in_memory::InMemoryVeterinarianRepository.new }
  let(:funds) { 100_000 }
  let(:zoo_repo) do
    in_memory::InMemoryZooRepository.new(
      domain::Zoo.new(name: '動物園', admission_fee: money.yen(2_000), funds: money.yen(funds))
    )
  end
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [veterinarians]) }
  let(:service) do
    command = commands::HireVeterinarianCommand.new(name: '山田')
                                               .bind(veterinarians:, zoo: zoo_repo, unit_of_work:)
    described_class.new(command: command)
  end

  describe '#call' do
    it 'name=\'山田\' で雇うと、result.value の id で find できる獣医が保存されること' do
      summary = service.call.value

      expect(veterinarians.find(summary.id).name).to eq('山田')
      expect(summary.name).to eq('山田')
    end

    it '採用の一時金(30,000円)ぶん残高が減ること' do
      service.call

      expect(zoo_repo.load.balance).to eq(balance.new(70_000))
    end

    context '残高が一時金に満たないとき' do
      let(:funds) { 10_000 }

      it 'result.error が InsufficientFunds になり、獣医は保存されないこと' do
        result = service.call

        expect(result.error).to be_a(Zoo::Domain::Errors::InsufficientFunds)
        expect(veterinarians.all).to be_empty
        expect(zoo_repo.load.balance).to eq(balance.new(10_000))
      end
    end
  end
end
