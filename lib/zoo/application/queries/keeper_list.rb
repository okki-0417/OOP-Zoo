# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class KeeperList
        def initialize(keepers:)
          @keepers = keepers
        end

        def call
          @keepers.all.map do |keeper|
            ReadModels::KeeperSummary.new(
              id: keeper.id.to_s,
              name: keeper.name,
              specialties: keeper.specialties.map(&:label).join('・')
            )
          end
        end
      end
    end
  end
end
