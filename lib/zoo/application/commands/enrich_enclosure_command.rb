# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      EnrichEnclosureCommand = Data.define(
        :keeper_id, :enclosure_id,
        :keepers, :enclosures, :unit_of_work
      ) do
        def initialize(keeper_id:, enclosure_id:, keepers: nil, enclosures: nil,
                       unit_of_work: nil)
          raise ArgumentError, 'keeper_id は必須です' if keeper_id.nil?
          raise ArgumentError, 'enclosure_id は必須です' if enclosure_id.nil?

          super
        end

        def bind(keepers:, enclosures:, unit_of_work:, **)
          with(keepers:, enclosures:, unit_of_work:)
        end
      end
    end
  end
end
