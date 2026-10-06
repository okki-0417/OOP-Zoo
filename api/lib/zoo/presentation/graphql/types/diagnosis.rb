# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Diagnosis < GraphQL::Schema::Enum
          %i[healthy sick injured dead].each { |diagnosis| value diagnosis.to_s.upcase, value: diagnosis }
        end
      end
    end
  end
end
