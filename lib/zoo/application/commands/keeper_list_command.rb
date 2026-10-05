# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      KeeperListCommand = Data.define(:keepers, :assignments) do
        def initialize(keepers: nil, assignments: nil)
          super
        end

        def bind(keepers:, assignments:, **)
          with(keepers:, assignments:)
        end
      end
    end
  end
end
