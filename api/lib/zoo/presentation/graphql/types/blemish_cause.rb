# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class BlemishCause < GraphQL::Schema::Enum
          %i[stressed sick weak].each { |cause| value cause.to_s.upcase, value: cause }
        end
      end
    end
  end
end
