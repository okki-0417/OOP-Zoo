# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::Sqlite::AnimalRepository do
  let(:repository) { described_class.new(Zoo::Infrastructure::Sqlite::Database.new) }

  it_behaves_like 'an animal repository'
end
