# frozen_string_literal: true

module Mutations
  class OperateDay < BaseMutation
    type Types::Operating, null: false

    def resolve
      ZooDay.of(current_zoo).run
    end
  end
end
