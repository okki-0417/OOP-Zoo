# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class StressorCause < GraphQL::Schema::Enum
          %i[filth boredom crowding loneliness maternal_separation social_conflict
             climate_discomfort hunger illness malnutrition].each do |cause|
            value cause.to_s.upcase, value: cause
          end
        end
      end
    end
  end
end
