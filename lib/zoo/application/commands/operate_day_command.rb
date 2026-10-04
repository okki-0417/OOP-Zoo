# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      OperateDayCommand = Data.define(
        :random,
        :animals, :enclosures, :housings, :keepers, :veterinarians, :zoo, :operatings, :unit_of_work
      ) do
        def initialize(random: Random.new, animals: nil, enclosures: nil, housings: nil, keepers: nil,
                       veterinarians: nil, zoo: nil, operatings: nil, unit_of_work: nil)
          super
        end

        def bind(animals:, enclosures:, housings:, keepers:, veterinarians:, zoo:, operatings:, unit_of_work:, **)
          with(animals:, enclosures:, housings:, keepers:, veterinarians:, zoo:, operatings:, unit_of_work:)
        end
      end
    end
  end
end
