# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class OperatingRepository
        include Domain::Repositories::OperatingRepository

        def initialize(database, mapper: OperatingMapper.new)
          @database = database
          @mapper = mapper
        end

        def save(operating)
          operatings.insert_conflict(:replace).insert(@mapper.to_row(operating))
          expenses.where(operating_id: operating.id.to_s).delete
          expenses.multi_insert(@mapper.to_expense_rows(operating))
          operating
        end

        def all
          rows = operatings.order(:day).all
          expenses_by_operating = expense_rows_of(rows.map { |row| row[:id] })
          rows.map do |row|
            @mapper.to_aggregate(row.transform_keys(&:to_s), expenses_by_operating.fetch(row[:id], []))
          end
        end

        def latest
          row = operatings.order(Sequel.desc(:day)).first
          row && @mapper.to_aggregate(row.transform_keys(&:to_s), expense_rows_of([row[:id]]).fetch(row[:id], []))
        end

        private

        def expense_rows_of(operating_ids)
          expenses.where(operating_id: operating_ids).order(:seq).all
                  .map { |row| row.transform_keys(&:to_s) }
                  .group_by { |row| row['operating_id'] }
        end

        def operatings
          @database.dataset(:operatings)
        end

        def expenses
          @database.dataset(:operating_expenses)
        end
      end
    end
  end
end
