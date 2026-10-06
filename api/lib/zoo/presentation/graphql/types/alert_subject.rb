# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class AlertSubject < GraphQL::Schema::Enum
          %i[zoo enclosure animal].each { |type| value type.to_s.upcase, value: type }
        end
      end
    end
  end
end
