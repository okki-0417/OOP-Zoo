# frozen_string_literal: true

class AddUserToZoos < ActiveRecord::Migration[8.1]
  def up
    add_reference :zoos, :user, foreign_key: true, index: { unique: true }
    select_values('SELECT id FROM zoos WHERE user_id IS NULL').each do |zoo_id|
      execute('INSERT INTO users (created_at, updated_at) VALUES (CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)')
      user_id = select_value('SELECT MAX(id) FROM users')
      execute("UPDATE zoos SET user_id = #{user_id} WHERE id = #{zoo_id}")
    end
    change_column_null :zoos, :user_id, false
  end

  def down
    remove_reference :zoos, :user
  end
end
