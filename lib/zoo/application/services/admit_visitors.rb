# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AdmitVisitors
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:admit_visitors) do
            @command.unit_of_work.run do
              zoo = @command.zoo.load
              zoo.admit_visitors(@command.count)
              @command.zoo.save(zoo)
              zoo.revenue
            end
          end
        end
      end
    end
  end
end
