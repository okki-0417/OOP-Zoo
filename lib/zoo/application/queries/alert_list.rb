# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class AlertList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:alert_list) do
            zoo = @command.zoo.load
            occupancies = @command.housings.all_occupancies
            occupants = occupancies.flat_map(&:to_a).select(&:alive?)

            [
              *zoo_alerts(zoo),
              *StaffingAlerts.new(
                zoo:, occupants:, keepers: @command.keepers.all, veterinarians: @command.veterinarians.all
              ).to_a,
              *occupancies.flat_map do |occupancy|
                EnclosureAlerts.new(occupancy:, keepers: @command.assignments.keepers_of(occupancy.enclosure)).to_a
              end,
              *occupancies.flat_map { |occupancy| housed_animal_alerts(occupancy, zoo.season) },
              *unhoused_alerts(occupants)
            ].sort_by(&:rank)
          end
        end

        private

        def zoo_alerts(zoo)
          return [] unless zoo.balance.negative?

          [ReadModels::Alert.about_zoo(zoo, severity: :critical, kind: :insolvent,
                                            message: "資金が赤字です(残高 #{zoo.balance})")]
        end

        def housed_animal_alerts(occupancy, season)
          occupancy.select(&:alive?).flat_map { |animal| AnimalAlerts.new(animal:, occupancy:, season:).to_a }
        end

        def unhoused_alerts(occupants)
          @command.animals.all.select(&:alive?).reject { |animal| occupants.include?(animal) }.map do |animal|
            ReadModels::Alert.about_animal(animal, severity: :warning, kind: :unhoused,
                                                   message: 'どのエリアにも収容されていません')
          end
        end
      end
    end
  end
end
