# frozen_string_literal: true

module Services
  class AdmitVisitors
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:admit_visitors) do
        ApplicationRecord.transaction do
          zoo = ::Zoo.current
          zoo.admit_visitors(@command.count)
          zoo.save!
          zoo.revenue
        end
      end
    end
  end
end
