# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::InMemory::InMemoryEnclosureAssignmentRepository do
  let(:repository) { described_class.new }

  def persist_keepers(*); end

  def persist_enclosures(*); end

  it_behaves_like 'an enclosure assignment repository'
end
