# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      KeeperSummary = Data.define(:id, :name, :specialties, :worked_minutes, :remaining_minutes, :enclosures) do
        def self.of(keeper, enclosures: [])
          new(
            id: keeper.id.to_s,
            name: keeper.name,
            specialties: keeper.specialties_label,
            worked_minutes: keeper.worked_minutes,
            remaining_minutes: keeper.remaining_minutes,
            enclosures: enclosures.map { |enclosure| StaffRef.of(enclosure) }
          )
        end

        def self.assigned(keeper, assignments:)
          of(keeper, enclosures: assignments.enclosures_of(keeper))
        end
      end
    end
  end
end
