# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class RunDays < Action
        def call(params)
          summary = @container.run_days.call(
            Application::Commands::RunDaysCommand.new(days: Integer(params['days']))
          )
          [200, Serializer.run_days_summary(summary)]
        end
      end
    end
  end
end
