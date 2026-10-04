# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      ZooReportCommand = Data.define(:housings, :zoo, :animals, :births) do
        def initialize(housings: nil, zoo: nil, animals: nil, births: nil)
          super
        end

        def bind(housings:, zoo:, animals:, births:, **)
          with(housings:, zoo:, animals:, births:)
        end
      end
    end
  end
end
