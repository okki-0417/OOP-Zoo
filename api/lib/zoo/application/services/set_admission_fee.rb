# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class SetAdmissionFee
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:set_admission_fee) do
            ApplicationRecord.transaction do
              zoo = Domain::Zoo.current
              zoo.change_admission_fee(Domain::Shared::Money.yen(@command.fee))
              zoo.save!
              zoo
            end
          end
        end
      end
    end
  end
end
