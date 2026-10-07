# frozen_string_literal: true

require 'graphql'

module Zoo
  module Presentation
    module Graphql
      module Mutations
        class BaseMutation < GraphQL::Schema::Mutation
          private

          def perform(use_case, **attributes)
            name = use_case.to_s.camelize
            command = Application::Commands.const_get("#{name}Command").new(**attributes)
            result = Application::Services.const_get(name).new(command:).call
            raise failure(result.error) if result.failure?

            result.value
          end

          def failure(error)
            GraphQL::ExecutionError.new(error.message, extensions: { code: error.class.name.split('::').last })
          end
        end
      end
    end
  end
end
