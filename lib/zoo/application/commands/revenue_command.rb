# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      RevenueCommand = Data.define(:zoo) do
        def initialize(zoo: nil)
          super
        end

        def bind(zoo:, **)
          with(zoo:)
        end
      end
    end
  end
end
