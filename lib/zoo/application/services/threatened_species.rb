# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class ThreatenedSpecies
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:threatened_species) do
            @command.housings.all_occupants
                    .select(&:threatened?)
                    .group_by(&:species)
                    .map { |species, members| { species:, count: members.size } }
          end
        end
      end
    end
  end
end
