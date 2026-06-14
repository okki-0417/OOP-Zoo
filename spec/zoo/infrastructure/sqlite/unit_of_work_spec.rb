# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Infrastructure::Sqlite::UnitOfWork do
  shared = Zoo::Domain::Shared
  sqlite = Zoo::Infrastructure::Sqlite

  let(:database) { sqlite::Database.new }
  let(:default_zoo) { Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: shared::Money.yen(2_000)) }
  let(:repository) { sqlite::ZooRepository.new(database, default_zoo) }
  let(:unit_of_work) { described_class.new(database) }

  describe '#run' do
    it 'ブロックの戻り値を返すこと' do
      expect(unit_of_work.run { 42 }).to eq(42)
    end

    it '例外が起きると save が本物のトランザクションで巻き戻ること' do
      repository.save(default_zoo) # 初期保存(収益0)

      expect do
        unit_of_work.run do
          zoo = repository.load
          zoo.admit_visitors(100)
          repository.save(zoo) # トランザクション内で更新
          raise 'boom'
        end
      end.to raise_error('boom')

      expect(repository.load.revenue).to eq(shared::Money.zero) # ロールバックで0のまま
    end
  end
end
