# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      AnimalListCommand = Data.define(:animals) do
        def initialize(animals: nil)
          super
        end

        def bind(animals:, **)
          with(animals:)
        end
      end
    end
  end
end
