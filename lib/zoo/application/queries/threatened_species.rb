# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class ThreatenedSpecies
        def initialize(housings:)
          @housings = housings
        end

        def call
          Domain::Occupancy.new(@housings.all).all_occupants
                           .select(&:threatened?)
                           .group_by(&:species)
                           .map { |species, members| to_read_model(species, members.size) }
        end

        private

        def to_read_model(species, count)
          status = species.conservation_status
          ReadModels::ExhibitedSpecies.new(
            name_ja: species.name_ja,
            status_code: status.code,
            status_label: status.label,
            count: count
          )
        end
      end
    end
  end
end
