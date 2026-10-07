# frozen_string_literal: true

require 'graphql'

class OopZooSchema < GraphQL::Schema
  query Types::Query
  mutation Types::Mutation

  rescue_from(ArgumentError) do |error|
    raise GraphQL::ExecutionError.new(error.message, extensions: { code: 'InvalidArgument' })
  end
end
