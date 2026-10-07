# frozen_string_literal: true

module Services
  class SetAdmissionFee
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:set_admission_fee) do
        ApplicationRecord.transaction do
          zoo = ::Zoo.current
          zoo.change_admission_fee(Money.yen(@command.fee))
          zoo.save!
          zoo
        end
      end
    end
  end
end
