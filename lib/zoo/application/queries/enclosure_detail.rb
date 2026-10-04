# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class EnclosureDetail
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:enclosure_detail) do
            enclosure = @command.enclosures.find(@command.enclosure_id)
            raise Errors::EnclosureNotFound, "エリア #{@command.enclosure_id} は存在しません" if enclosure.nil?

            ReadModels::EnclosureProfile.housed(enclosure, housings: @command.housings)
          end
        end
      end
    end
  end
end
