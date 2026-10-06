# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      RunDaysCommand = Data.define(
        :days, :random,
        :animals, :enclosures, :housings, :keepers, :veterinarians, :zoo, :operatings, :unit_of_work
      ) do
        def initialize(days:, random: Random.new, animals: nil, enclosures: nil, housings: nil, keepers: nil,
                       veterinarians: nil, zoo: nil, operatings: nil, unit_of_work: nil)
          raise ArgumentError, 'days は必須です' if days.nil?
          raise ArgumentError, 'days は1以上でなければなりません' unless days.is_a?(Integer) && days.positive?

          super
        end

        def bind(animals:, enclosures:, housings:, keepers:, veterinarians:, zoo:, operatings:, unit_of_work:, **)
          with(animals:, enclosures:, housings:, keepers:, veterinarians:, zoo:, operatings:, unit_of_work:)
        end

        def operate_day_command
          OperateDayCommand.new(random:).bind(
            animals:, enclosures:, housings:, keepers:, veterinarians:, zoo:, operatings:, unit_of_work:
          )
        end
      end
    end
  end
end
