# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AdmitVisitors
        def initialize(zoo:, unit_of_work:)
          @zoo = zoo
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            zoo = @zoo.load
            zoo.admit_visitors(command.count)
            @zoo.save(zoo)
            zoo.revenue
          end
        end
      end
    end
  end
end
