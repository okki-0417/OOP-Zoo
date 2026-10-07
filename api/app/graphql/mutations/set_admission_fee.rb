# frozen_string_literal: true

module Mutations
  class SetAdmissionFee < BaseMutation
    type Types::Zoo, null: false

    argument :fee, Integer

    def resolve(**)
      perform(:set_admission_fee, **)
    end
  end
end
