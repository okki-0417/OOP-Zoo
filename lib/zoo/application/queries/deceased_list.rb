# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class DeceasedList
        def initialize(event_store:)
          @event_store = event_store
        end

        def call
          @event_store.all
                      .grep(Domain::Events::AnimalDied)
                      .map { |event| ReadModels::DeceasedRecord.new(name: event.animal.name.to_s, species: event.animal.species_name, cause: event.cause) }
        end
      end
    end
  end
end
