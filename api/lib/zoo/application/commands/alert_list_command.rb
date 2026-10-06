# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      AlertListCommand = Data.define(:animals, :housings, :keepers, :veterinarians, :assignments, :zoo) do
        def initialize(animals: nil, housings: nil, keepers: nil, veterinarians: nil, assignments: nil, zoo: nil)
          super
        end

        def bind(animals:, housings:, keepers:, veterinarians:, assignments:, zoo:, **)
          with(animals:, housings:, keepers:, veterinarians:, assignments:, zoo:)
        end
      end
    end
  end
end
