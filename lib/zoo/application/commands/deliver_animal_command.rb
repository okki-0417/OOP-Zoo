# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      DeliverAnimalCommand = Data.define(:dam_id, :enclosure_id, :keeper_id) do
        def initialize(dam_id:, enclosure_id:, keeper_id: nil)
          raise ArgumentError, 'dam_id は必須です' if dam_id.nil?
          raise ArgumentError, 'enclosure_id は必須です' if enclosure_id.nil?

          super
        end
      end
    end
  end
end
