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
            @command.unit_of_work.run do
              zoo = @command.zoo.load
              zoo.change_admission_fee(Domain::Shared::Money.yen(@command.fee))
              @command.zoo.save(zoo)
              zoo
            end
          end
        end
      end
    end
  end
end
