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
            ApplicationRecord.transaction do
              zoo = Domain::Zoo.current
              zoo.admit_visitors(@command.count)
              zoo.save!
              zoo.revenue
            end
          end
        end
      end
    end
  end
end
