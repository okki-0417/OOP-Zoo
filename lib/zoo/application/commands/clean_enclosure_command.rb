# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      CleanEnclosureCommand = Data.define(
        :keeper_id, :enclosure_id, :amount,
        :keepers, :enclosures, :housings, :unit_of_work
      ) do
        def initialize(keeper_id:, enclosure_id:, amount: 100, keepers: nil, enclosures: nil, housings: nil,
                       unit_of_work: nil)
          raise ArgumentError, 'keeper_id は必須です' if keeper_id.nil?
          raise ArgumentError, 'enclosure_id は必須です' if enclosure_id.nil?

          super
        end

        def bind(keepers:, enclosures:, housings:, unit_of_work:, **)
          with(keepers:, enclosures:, housings:, unit_of_work:)
        end
      end
    end
  end
end
