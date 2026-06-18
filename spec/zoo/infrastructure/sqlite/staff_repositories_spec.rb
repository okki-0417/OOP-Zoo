# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SQLite staff repositories' do
  taxonomy = Zoo::Domain
  staff    = Zoo::Domain
  sqlite   = Zoo::Infrastructure::Sqlite

  let(:database) { sqlite::Database.new }

  describe sqlite::KeeperRepository do
    let(:repository) { described_class.new(database) }

    it '専門綱つきの飼育員を保存・復元できること' do
      keeper = staff::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal, taxonomy::TaxonClass.bird])
      repository.save(keeper)

      found = repository.find(keeper.id)

      expect(found.name).to eq('田中')
      expect(found.specialties.map(&:value)).to contain_exactly(:mammal, :bird)
    end
  end

  describe sqlite::VeterinarianRepository do
    let(:repository) { described_class.new(database) }

    it '獣医を保存・復元できること' do
      vet = staff::Veterinarian.new(name: '山田')
      repository.save(vet)

      expect(repository.find(vet.id).name).to eq('山田')
      expect(repository.all.size).to eq(1)
    end
  end
end
