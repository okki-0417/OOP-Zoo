# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::InMemory::InMemoryZooRepository do
  shared = Zoo::Domain::Shared

  let(:default_zoo) { Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: shared::Money.yen(2_000)) }
  let(:repository) { described_class.new(default_zoo) }

  it_behaves_like 'a zoo repository'
end
