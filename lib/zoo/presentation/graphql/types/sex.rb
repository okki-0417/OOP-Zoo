# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Sex < GraphQL::Schema::Enum
          Domain::Animal::Sex::VALUES.each_key { |sex| value sex.to_s.upcase, value: sex }
        end
      end
    end
  end
end
