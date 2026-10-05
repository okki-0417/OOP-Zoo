# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class AlertList
        class StaffingAlerts
          def initialize(zoo:, occupants:, keepers:, veterinarians:)
            @zoo = zoo
            @occupants = occupants
            @keepers = keepers
            @veterinarians = veterinarians
          end

          def to_a
            [*uncovered_taxon_alerts, missing_veterinarian_alert].compact
          end

          private

          def alert(kind, message)
            ReadModels::Alert.about_zoo(@zoo, severity: :warning, kind:, message:)
          end

          def uncovered_taxon_alerts
            @occupants.map(&:taxon_class).uniq
                      .reject { |taxon| @keepers.any? { |keeper| keeper.specialized_in?(taxon) } }
                      .map { |taxon| alert(:no_keeper, "#{taxon.label}を世話できる飼育員がいません") }
          end

          def missing_veterinarian_alert
            return if @occupants.none?(&:sick?) || @veterinarians.any?

            alert(:no_veterinarian, '病気の動物がいますが、獣医がいません')
          end
        end
      end
    end
  end
end
