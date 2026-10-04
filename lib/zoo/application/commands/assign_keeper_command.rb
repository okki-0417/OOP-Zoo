# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      AssignKeeperCommand = Data.define(
        :keeper_id, :enclosure_id,
        :keepers, :enclosures, :housings, :assignments, :unit_of_work
      ) do
        def initialize(keeper_id:, enclosure_id:, keepers: nil, enclosures: nil, housings: nil, assignments: nil,
                       unit_of_work: nil)
          raise ArgumentError, 'keeper_id は必須です' if keeper_id.nil?
          raise ArgumentError, 'enclosure_id は必須です' if enclosure_id.nil?

          super
        end

        def bind(keepers:, enclosures:, housings:, assignments:, unit_of_work:, **)
          with(keepers:, enclosures:, housings:, assignments:, unit_of_work:)
        end
      end
    end
  end
end
