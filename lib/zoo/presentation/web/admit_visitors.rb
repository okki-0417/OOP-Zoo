# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class AdmitVisitors < Action
        def call(params)
          revenue = @container.admit_visitors.call(
            Application::Commands::AdmitVisitorsCommand.new(count: Integer(params['count']))
          )
          [200, { revenue: revenue.yen }]
        end
      end
    end
  end
end
