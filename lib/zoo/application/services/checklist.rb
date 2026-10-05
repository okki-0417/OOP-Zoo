# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class Checklist
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:checklist) do
            occupancies = @command.housings.all_occupancies.select { |occupancy| occupancy.any?(&:alive?) }
            residents = occupancies.flat_map(&:to_a).select(&:alive?)
            enclosures = occupancies.map(&:enclosure)

            [
              chore(:feeding, '給餌', residents.map { |animal| { type: :animal, subject: animal, done: animal.fed_today? } }),
              chore(:treatment, '治療', patients.map { |animal| { type: :animal, subject: animal, done: false } }),
              chore(:cleaning, '清掃', enclosures.map { |enclosure| { type: :enclosure, subject: enclosure, done: !enclosure.soiled? } }),
              chore(:enrichment, '遊具の補充', enclosures.map { |enclosure| { type: :enclosure, subject: enclosure, done: !enclosure.dull? } })
            ]
          end
        end

        private

        def patients
          @command.animals.all.select { |animal| animal.alive? && animal.sick? }
        end

        def chore(kind, label, items)
          { kind:, label:, items: }
        end
      end
    end
  end
end
