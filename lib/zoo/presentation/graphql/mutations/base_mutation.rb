# frozen_string_literal: true

require 'graphql'

module Zoo
  module Presentation
    module Graphql
      module Mutations
        class BaseMutation < GraphQL::Schema::Mutation
          private

          def perform(use_case, **attributes)
            command = Application::Commands.const_get("#{use_case.to_s.split('_').map(&:capitalize).join}Command")
            result = context[:container].public_send(use_case, command.new(**attributes))
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
