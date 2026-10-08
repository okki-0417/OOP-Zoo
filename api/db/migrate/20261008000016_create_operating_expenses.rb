# frozen_string_literal: true

class CreateOperatingExpenses < ActiveRecord::Migration[8.1]
  def up
    create_table :operating_expenses do |t|
      t.references :operating, null: false, foreign_key: true
      t.string :category, null: false
      t.string :subject, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :amount, null: false
      t.timestamps
    end

    select_rows('SELECT id, expenses FROM operatings').each do |operating_id, expenses|
      JSON.parse(expenses).each do |expense|
        execute(<<~SQL.squish)
          INSERT INTO operating_expenses (operating_id, category, subject, quantity, amount, created_at, updated_at)
          VALUES (#{operating_id}, #{quote(expense['category'])}, #{quote(expense['subject'])},
                  #{Integer(expense['quantity'])}, #{Integer(expense['amount'])}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        SQL
      end
    end

    remove_column :operatings, :expenses
  end

  def down
    add_column :operatings, :expenses, :text, null: false, default: '[]'
    execute(<<~SQL.squish)
      UPDATE operatings SET expenses = COALESCE(
        (SELECT JSON_GROUP_ARRAY(JSON_OBJECT('category', category, 'subject', subject, 'quantity', quantity, 'amount', amount))
         FROM operating_expenses WHERE operating_expenses.operating_id = operatings.id), '[]'
      )
    SQL
    drop_table :operating_expenses
  end
end
