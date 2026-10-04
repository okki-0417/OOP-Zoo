# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::InMemory::InMemorySpeciesRepository do
  catalog = Zoo::Domain::SpeciesCatalog

  let(:repository) { described_class.new }

  describe '#find' do
    it 'find("lion") はライオンの Species を返すこと' do
      expect(repository.find('lion')).to eq(catalog.lion)
    end

    it 'find(:lion) のようにシンボルでも引けること' do
      expect(repository.find(:lion)).to eq(catalog.lion)
    end

    it 'find("dragon") のように未知のコードは nil を返すこと' do
      expect(repository.find('dragon')).to be_nil
    end
  end

  describe '#all_by_code' do
    it 'カタログの全キーをコード、Species を値とする Hash を返すこと' do
      all = repository.all_by_code

      expect(all.keys).to eq(catalog.keys)
      expect(all[:lion]).to eq(catalog.lion)
    end
  end

  it 'Domain::Repositories::SpeciesRepository を実装していること' do
    expect(described_class).to include(Zoo::Domain::Repositories::SpeciesRepository)
  end
end
