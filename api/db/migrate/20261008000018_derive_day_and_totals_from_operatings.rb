# frozen_string_literal: true

class DeriveDayAndTotalsFromOperatings < ActiveRecord::Migration[8.1]
  def up
    remove_column :zoos, :day
    remove_column :zoos, :visitor_count
    remove_column :zoos, :revenue
    remove_column :operatings, :total_visitors
    remove_column :operatings, :total_revenue
  end

  def down
    add_column :operatings, :total_revenue, :integer, null: false, default: 0
    add_column :operatings, :total_visitors, :integer, null: false, default: 0
    add_column :zoos, :revenue, :integer, null: false, default: 0
    add_column :zoos, :visitor_count, :integer, null: false, default: 0
    add_column :zoos, :day, :integer, null: false, default: 0
    execute(<<~SQL.squish)
      UPDATE operatings SET
        total_visitors = (SELECT SUM(earlier.visitors) FROM operatings earlier
                          WHERE earlier.zoo_id = operatings.zoo_id AND earlier.day <= operatings.day),
        total_revenue = (SELECT SUM(earlier.income) FROM operatings earlier
                         WHERE earlier.zoo_id = operatings.zoo_id AND earlier.day <= operatings.day)
    SQL
    execute(<<~SQL.squish)
      UPDATE zoos SET
        day = (SELECT COUNT(*) FROM operatings WHERE operatings.zoo_id = zoos.id),
        visitor_count = COALESCE((SELECT SUM(visitors) FROM operatings WHERE operatings.zoo_id = zoos.id), 0),
        revenue = COALESCE((SELECT SUM(income) FROM operatings WHERE operatings.zoo_id = zoos.id), 0)
    SQL
  end
end
