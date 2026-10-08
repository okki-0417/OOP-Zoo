# frozen_string_literal: true

module Mutations
  class SetAdmissionFee < BaseMutation
    type Types::Zoo, null: false

    argument :fee, Integer

    def resolve(fee:)
      current_zoo.change_admission_fee(Money.yen(fee)).tap(&:save!)
    end
  end
end
