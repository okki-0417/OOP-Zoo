# frozen_string_literal: true

require 'graphql'

module Zoo
  module Presentation
    module Graphql
      class Schema < GraphQL::Schema
        query Types::Query
        mutation Types::Mutation

        rescue_from(ArgumentError) do |error|
          raise GraphQL::ExecutionError.new(error.message, extensions: { code: 'InvalidArgument' })
        end
      end
    end
  end
end
