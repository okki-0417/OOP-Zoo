# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      MakeRoundsCommand = Data.define(
        :keeper_id,
        :keepers, :animals, :enclosures, :housings, :assignments, :foods, :unit_of_work
      ) do
        def initialize(keeper_id:, keepers: nil, animals: nil, enclosures: nil, housings: nil, assignments: nil,
                       foods: nil, unit_of_work: nil)
          raise ArgumentError, 'keeper_id は必須です' if keeper_id.nil?

          super
        end

        def bind(keepers:, animals:, enclosures:, housings:, assignments:, foods:, unit_of_work:, **)
          with(keepers:, animals:, enclosures:, housings:, assignments:, foods:, unit_of_work:)
        end
      end
    end
  end
end
