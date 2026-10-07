# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AlertList
        SEVERITIES = %i[critical warning notice].freeze

        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:alert_list) do
            zoo = Domain::Zoo.current
            occupancies = Domain::Occupancy.all
            occupants = occupancies.flat_map(&:to_a).select(&:alive?)

            [
              *zoo_alerts(zoo),
              *StaffingAlerts.new(
                zoo:, occupants:, keepers: Domain::Keeper.all.to_a, veterinarians: Domain::Veterinarian.all.to_a
              ).to_a,
              *occupancies.flat_map do |occupancy|
                EnclosureAlerts.new(occupancy:, keepers: occupancy.enclosure.keepers.to_a).to_a
              end,
              *occupancies.flat_map { |occupancy| housed_animal_alerts(occupancy, zoo.season) },
              *unhoused_alerts
            ].sort_by { |alert| rank(alert) }
          end
        end

        private

        def zoo_alerts(zoo)
          return [] unless zoo.balance.negative?

          [{ severity: :critical, kind: :insolvent, subject_type: :zoo, subject: zoo,
             message: "資金が赤字です(残高 #{zoo.balance})" }]
        end

        def rank(alert)
          [SEVERITIES.index(alert[:severity]), alert[:subject_type] == :zoo ? 0 : 1, alert[:subject].name.to_s]
        end

        def housed_animal_alerts(occupancy, season)
          occupancy.select(&:alive?).flat_map { |animal| AnimalAlerts.new(animal:, occupancy:, season:).to_a }
        end

        def unhoused_alerts
          Domain::Animal.alive.where(enclosure: nil).map do |animal|
            { severity: :warning, kind: :unhoused, subject_type: :animal, subject: animal,
              message: 'どのエリアにも収容されていません' }
          end
        end
      end
    end
  end
end
