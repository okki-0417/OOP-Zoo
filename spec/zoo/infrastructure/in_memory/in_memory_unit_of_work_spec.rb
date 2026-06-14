# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::InMemory::InMemoryUnitOfWork do
  describe '#run' do
    it 'ブロックの戻り値をそのまま返すこと' do
      result = described_class.new.run { 42 }

      expect(result).to eq(42)
    end

    it 'ブロック内で発生した例外をそのまま伝播すること' do
      expect { described_class.new.run { raise 'boom' } }.to raise_error('boom')
    end

    it 'ネストして呼んでもデッドロックせずに内側の戻り値を返すこと' do
      uow = described_class.new

      result = uow.run { uow.run { 'inner' } }

      expect(result).to eq('inner')
    end

    it 'ブロック内で例外が起きると、登録リポジトリへの save が巻き戻されること' do
      catalog = Zoo::Domain::Taxonomy::SpeciesCatalog
      animals = Zoo::Infrastructure::InMemory::InMemoryAnimalRepository.new
      lion = build_adult(catalog.lion, name: 'レオ')
      uow = described_class.new(repositories: [animals])

      expect do
        uow.run do
          animals.save(lion)
          raise 'boom'
        end
      end.to raise_error('boom')

      expect(animals.find(lion.id)).to be_nil
    end
  end
end
