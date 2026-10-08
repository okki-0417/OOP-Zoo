# frozen_string_literal: true

class RemoveBuzzFromZoos < ActiveRecord::Migration[8.1]
  def change
    remove_column :zoos, :buzz, :integer, null: false, default: 0
  end
end
