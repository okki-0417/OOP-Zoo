# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      KeeperListCommand = Data.define(:keepers) do
        def initialize(keepers: nil)
          super
        end

        def bind(keepers:, **)
          with(keepers:)
        end
      end
    end
  end
end
