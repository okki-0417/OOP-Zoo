# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class EnclosureDetail
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:enclosure_detail) do
            enclosure = @command.enclosures.find(@command.enclosure_id)
            raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if enclosure.nil?

            {
              enclosure:,
              occupants: @command.housings.occupants_of(enclosure),
              keepers: @command.assignments.keepers_of(enclosure)
            }
          end
        end
      end
    end
  end
end
