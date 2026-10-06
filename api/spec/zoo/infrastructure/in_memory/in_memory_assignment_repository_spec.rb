# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::InMemory::InMemoryAssignmentRepository do
  let(:repository) { described_class.new }

  def persist_keepers(*); end

  def persist_enclosures(*); end

  it_behaves_like 'an assignment repository'
end
