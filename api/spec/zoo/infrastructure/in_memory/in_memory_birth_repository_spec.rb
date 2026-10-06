# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::InMemory::InMemoryBirthRepository do
  let(:repository) { described_class.new }

  def persist_animals(*); end

  it_behaves_like 'a birth repository'
end
