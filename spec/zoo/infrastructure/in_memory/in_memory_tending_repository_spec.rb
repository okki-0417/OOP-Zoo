# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::InMemory::InMemoryTendingRepository do
  let(:repository) { described_class.new }

  def persist_keepers(*); end

  def persist_enclosures(*); end

  it_behaves_like 'a tending repository'
end
