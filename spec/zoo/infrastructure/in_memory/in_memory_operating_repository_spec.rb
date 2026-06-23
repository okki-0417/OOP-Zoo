# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::InMemory::InMemoryOperatingRepository do
  let(:repository) { described_class.new }

  it_behaves_like 'an operating repository'
end
