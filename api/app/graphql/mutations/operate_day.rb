# frozen_string_literal: true

module Mutations
  class OperateDay < BaseMutation
    type Types::Operating, null: false

    def resolve
      ZooDay.current.run
    end
  end
end
