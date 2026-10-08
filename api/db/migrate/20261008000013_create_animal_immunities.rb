# frozen_string_literal: true

class CreateAnimalImmunities < ActiveRecord::Migration[8.1]
  def up
    create_table :animal_immunities do |t|
      t.references :animal, null: false, foreign_key: true
      t.string :illness, null: false
      t.timestamps
    end
    add_index :animal_immunities, %i[animal_id illness], unique: true

    select_rows("SELECT id, immunities FROM animals WHERE immunities <> ''").each do |animal_id, immunities|
      immunities.split(',').uniq.each do |illness|
        execute(<<~SQL.squish)
          INSERT INTO animal_immunities (animal_id, illness, created_at, updated_at)
          VALUES (#{animal_id}, #{quote(illness)}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        SQL
      end
    end

    remove_column :animals, :immunities
  end

  def down
    add_column :animals, :immunities, :string, null: false, default: ''
    execute(<<~SQL.squish)
      UPDATE animals SET immunities = COALESCE(
        (SELECT GROUP_CONCAT(illness, ',') FROM animal_immunities WHERE animal_immunities.animal_id = animals.id), ''
      )
    SQL
    drop_table :animal_immunities
  end
end
