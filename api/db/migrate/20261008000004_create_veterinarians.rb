# frozen_string_literal: true

class CreateVeterinarians < ActiveRecord::Migration[8.1]
  def change
    create_table :veterinarians do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
