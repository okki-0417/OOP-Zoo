# frozen_string_literal: true

class KeepReputationPerOperating < ActiveRecord::Migration[8.1]
  def up
    change_column :operatings, :reputation, :float, null: false
    execute(<<~SQL.squish)
      UPDATE operatings SET reputation = (SELECT zoos.reputation FROM zoos WHERE zoos.id = operatings.zoo_id)
      WHERE operatings.id = (
        SELECT latest.id FROM operatings latest WHERE latest.zoo_id = operatings.zoo_id ORDER BY latest.day DESC, latest.id DESC LIMIT 1
      )
    SQL
    remove_column :zoos, :reputation
  end

  def down
    add_column :zoos, :reputation, :float, null: false, default: 50.0
    execute(<<~SQL.squish)
      UPDATE zoos SET reputation = COALESCE(
        (SELECT reputation FROM operatings WHERE operatings.zoo_id = zoos.id ORDER BY day DESC, id DESC LIMIT 1), 50.0
      )
    SQL
    change_column :operatings, :reputation, :integer, null: false
  end
end
