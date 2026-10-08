# frozen_string_literal: true

class CreateAnimalPregnancies < ActiveRecord::Migration[8.1]
  def up
    create_table :animal_pregnancies do |t|
      t.references :dam, null: false, foreign_key: { to_table: :animals }
      t.string :sex, null: false
      t.integer :gestation_days, null: false, default: 0
      t.float :inbreeding_coefficient, null: false, default: 0.0
      t.string :outcome
      t.timestamps
    end
    add_index :animal_pregnancies, :dam_id, unique: true, where: 'outcome IS NULL', name: 'index_animal_pregnancies_ongoing'

    execute(<<~SQL.squish)
      INSERT INTO animal_pregnancies (dam_id, sex, gestation_days, inbreeding_coefficient, created_at, updated_at)
      SELECT id, pregnancy_sex, COALESCE(gestation_days, 0), COALESCE(pregnancy_inbreeding, 0.0), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM animals WHERE pregnancy_sex IS NOT NULL
    SQL

    remove_column :animals, :pregnancy_sex
    remove_column :animals, :gestation_days
    remove_column :animals, :pregnancy_inbreeding
    remove_column :animals, :miscarried
  end

  def down
    add_column :animals, :pregnancy_sex, :string
    add_column :animals, :gestation_days, :integer
    add_column :animals, :pregnancy_inbreeding, :float
    add_column :animals, :miscarried, :boolean, null: false, default: false
    execute(<<~SQL.squish)
      UPDATE animals SET
        pregnancy_sex = (SELECT sex FROM animal_pregnancies WHERE dam_id = animals.id AND outcome IS NULL),
        gestation_days = (SELECT gestation_days FROM animal_pregnancies WHERE dam_id = animals.id AND outcome IS NULL),
        pregnancy_inbreeding = (SELECT inbreeding_coefficient FROM animal_pregnancies WHERE dam_id = animals.id AND outcome IS NULL)
    SQL
    drop_table :animal_pregnancies
  end
end
