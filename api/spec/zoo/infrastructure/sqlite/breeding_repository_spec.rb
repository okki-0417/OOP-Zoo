# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::Sqlite::BreedingRepository do
  let(:database) { Zoo::Infrastructure::Sqlite::Database.new }
  let(:animals) { Zoo::Infrastructure::Sqlite::AnimalRepository.new(database) }
  let(:repository) { described_class.new(database, animals) }

  def persist_animals(*list)
    list.each { |animal| animals.save(animal) }
  end

  it_behaves_like 'a breeding repository'
end
