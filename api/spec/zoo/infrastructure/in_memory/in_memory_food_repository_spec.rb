# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::InMemory::InMemoryFoodRepository do
  catalog = Zoo::Domain::FoodCatalog

  let(:repository) { described_class.new }

  describe '#find' do
    it 'find("chicken") は鶏肉の Food を返すこと' do
      expect(repository.find('chicken')).to eq(catalog.chicken)
    end

    it 'find("caviar") のように未知のコードは nil を返すこと' do
      expect(repository.find('caviar')).to be_nil
    end
  end

  describe '#all_by_code' do
    it 'カタログの全キーをコード、Food を値とする Hash を返すこと' do
      all = repository.all_by_code

      expect(all.keys).to eq(catalog.keys)
      expect(all[:chicken]).to eq(catalog.chicken)
    end
  end

  it 'Domain::Repositories::FoodRepository を実装していること' do
    expect(described_class).to include(Zoo::Domain::Repositories::FoodRepository)
  end
end
