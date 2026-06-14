# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      # ZooRepository ポートの SQLite 実装。SQL の発行を担い、行⇄集約の変換は
      # ZooMapper に委譲する。未保存なら既定の動物園を返す。
      class ZooRepository
        include Domain::Repositories::ZooRepository

        def initialize(database, default_zoo, mapper: ZooMapper.new)
          @database = database
          @default_zoo = default_zoo
          @mapper = mapper
        end

        def load
          row = @database.get_first_row('SELECT * FROM zoo WHERE id = 1')
          row ? @mapper.to_zoo(row) : @default_zoo
        end

        def save(zoo)
          row = @mapper.to_row(zoo)
          @database.execute(
            'INSERT OR REPLACE INTO zoo (id, name, admission_fee, revenue, visitor_count, balance, reputation, day) ' \
            'VALUES (1, ?, ?, ?, ?, ?, ?, ?)',
            row[:name], row[:admission_fee], row[:revenue], row[:visitor_count], row[:balance], row[:reputation],
            row[:day]
          )
          zoo
        end
      end
    end
  end
end
