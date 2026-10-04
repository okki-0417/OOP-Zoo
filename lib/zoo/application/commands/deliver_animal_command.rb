# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      DeliverAnimalCommand = Data.define(
        :dam_id, :enclosure_id, :keeper_id,
        :animals, :enclosures, :housings, :keepers, :breedings, :births, :zoo, :unit_of_work
      ) do
        def initialize(dam_id:, enclosure_id:, keeper_id: nil, animals: nil, enclosures: nil, housings: nil,
                       keepers: nil, breedings: nil, births: nil, zoo: nil, unit_of_work: nil)
          raise ArgumentError, 'dam_id は必須です' if dam_id.nil?
          raise ArgumentError, 'enclosure_id は必須です' if enclosure_id.nil?

          super
        end

        def bind(animals:, enclosures:, housings:, keepers:, breedings:, births:, zoo:, unit_of_work:, **)
          with(animals:, enclosures:, housings:, keepers:, breedings:, births:, zoo:, unit_of_work:)
        end
      end
    end
  end
end
