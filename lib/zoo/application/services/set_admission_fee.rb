# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class SetAdmissionFee
        def initialize(zoo:, unit_of_work:)
          @zoo = zoo
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            zoo = @zoo.load
            zoo.change_admission_fee(command.fee)
            @zoo.save(zoo)
            zoo.admission_fee
          end
        end
      end
    end
  end
end
