# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      OpenForADayCommand = Data.define(:season, :enclosures, :animals, :housings, :unit_of_work) do
        def initialize(season: Domain::Season.spring, enclosures: nil, animals: nil, housings: nil, unit_of_work: nil)
          super
        end

        def bind(enclosures:, animals:, housings:, unit_of_work:, **)
          with(enclosures:, animals:, housings:, unit_of_work:)
        end
      end
    end
  end
end
