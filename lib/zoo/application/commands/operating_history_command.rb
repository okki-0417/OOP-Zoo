# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      OperatingHistoryCommand = Data.define(:operatings) do
        def initialize(operatings: nil)
          super
        end

        def bind(operatings:, **)
          with(operatings:)
        end
      end
    end
  end
end
