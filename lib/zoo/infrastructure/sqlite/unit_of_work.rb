# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      # UnitOfWork ポートの SQLite 実装。本物の BEGIN/COMMIT/ROLLBACK で包む。
      # in-memory 版の「浅いスナップショット」の制約はここでは無い(実トランザクション)。
      class UnitOfWork
        include Application::UnitOfWork

        def initialize(database)
          @database = database
        end

        # 既にトランザクション中なら新たに開かず合流する(SQLite は素のネストを許さないため)。
        # これで OperateDay→OpenForADay のようなネストしたユースケースも単一トランザクションになる。
        def run(&block)
          return block.call if @database.transaction_active?

          @database.transaction(&block)
        end
      end
    end
  end
end
