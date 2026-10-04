# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      KeeperSummary = Data.define(:id, :name, :specialties) do
        def self.of(keeper)
          new(id: keeper.id.to_s, name: keeper.name, specialties: keeper.specialties_label)
        end
      end
    end
  end
end
