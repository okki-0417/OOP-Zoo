# frozen_string_literal: true

class DeriveBalanceFromLedger < ActiveRecord::Migration[8.1]
  def up
    create_table :acquirings do |t|
      t.references :zoo, null: false, foreign_key: true
      t.references :animal, null: false, foreign_key: true, index: { unique: true }
      t.integer :day, null: false
      t.integer :cost, null: false
      t.timestamps
    end

    create_table :constructings do |t|
      t.references :zoo, null: false, foreign_key: true
      t.references :enclosure, null: false, foreign_key: true, index: { unique: true }
      t.integer :day, null: false
      t.integer :cost, null: false
      t.timestamps
    end

    create_table :hirings do |t|
      t.references :zoo, null: false, foreign_key: true
      t.references :employee, polymorphic: true, null: false, index: { unique: true }
      t.integer :day, null: false
      t.integer :cost, null: false
      t.timestamps
    end

    add_column :zoos, :opening_funds, :integer, null: false, default: 0
    execute(<<~SQL.squish)
      UPDATE zoos SET opening_funds = balance - COALESCE(
        (SELECT SUM(income - cost) FROM operatings WHERE operatings.zoo_id = zoos.id), 0
      )
    SQL
    remove_column :zoos, :balance
    remove_column :operatings, :balance
  end

  def down
    add_column :operatings, :balance, :integer, null: false, default: 0
    add_column :zoos, :balance, :integer, null: false, default: 0
    execute(<<~SQL.squish)
      UPDATE zoos SET balance = opening_funds
        + COALESCE((SELECT SUM(income - cost) FROM operatings WHERE operatings.zoo_id = zoos.id), 0)
        - COALESCE((SELECT SUM(cost) FROM acquirings WHERE acquirings.zoo_id = zoos.id), 0)
        - COALESCE((SELECT SUM(cost) FROM constructings WHERE constructings.zoo_id = zoos.id), 0)
        - COALESCE((SELECT SUM(cost) FROM hirings WHERE hirings.zoo_id = zoos.id), 0)
    SQL
    remove_column :zoos, :opening_funds
    drop_table :hirings
    drop_table :constructings
    drop_table :acquirings
  end
end
