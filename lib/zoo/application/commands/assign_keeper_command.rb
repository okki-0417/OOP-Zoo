# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      AssignKeeperCommand = Data.define(:keeper_id, :enclosure_id) do
        def initialize(keeper_id:, enclosure_id:)
          raise ArgumentError, 'keeper_id は必須です' if keeper_id.nil?
          raise ArgumentError, 'enclosure_id は必須です' if enclosure_id.nil?

          super
        end
      end
    end
  end
end
