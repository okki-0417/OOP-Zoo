# frozen_string_literal: true

require 'graphql'

module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    def resolve_with_support(**)
      ApplicationRecord.transaction { super }
    rescue ActiveRecord::RecordNotFound => e
      raise GraphQL::ExecutionError.new(
        "#{e.model.constantize.model_name.human} #{e.id} は存在しません", extensions: { code: "#{e.model}NotFound" }
      )
    rescue Errors::DomainError, ActiveRecord::RecordInvalid => e
      raise failure(e)
    end

    private

    def current_zoo
      context[:current_zoo]
    end

    def failure(error)
      GraphQL::ExecutionError.new(error.message, extensions: { code: error.class.name.split('::').last })
    end
  end
end
