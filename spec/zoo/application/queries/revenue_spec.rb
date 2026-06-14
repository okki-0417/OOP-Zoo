# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Queries::Revenue do
  shared    = Zoo::Domain::Shared
  in_memory = Zoo::Infrastructure::InMemory

  describe '#call' do
    it '来園者を受け入れた後の累計収益(2000円×10人=20,000円)を返すこと' do
      zoo_aggregate = Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: shared::Money.yen(2000))
      zoo_aggregate.admit_visitors(10)
      zoo = in_memory::InMemoryZooRepository.new(zoo_aggregate)

      expect(described_class.new(zoo: zoo).call).to eq(shared::Money.yen(20_000))
    end
  end
end
