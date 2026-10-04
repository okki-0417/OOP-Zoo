# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      RunDaysCommand = Data.define(:days, :enclosures, :animals, :housings, :unit_of_work) do
        def initialize(days:, enclosures: nil, animals: nil, housings: nil, unit_of_work: nil)
          raise ArgumentError, 'days は必須です' if days.nil?
          raise ArgumentError, 'days は1以上でなければなりません' unless days.is_a?(Integer) && days.positive?

          super
        end

        def bind(enclosures:, animals:, housings:, unit_of_work:, **)
          with(enclosures:, animals:, housings:, unit_of_work:)
        end
      end
    end
  end
end
