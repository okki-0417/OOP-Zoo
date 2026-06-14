# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      CleanEnclosureCommand = Data.define(:keeper_id, :enclosure_id, :amount) do
        def initialize(keeper_id:, enclosure_id:, amount: 100)
          raise ArgumentError, 'keeper_id は必須です' if keeper_id.nil?
          raise ArgumentError, 'enclosure_id は必須です' if enclosure_id.nil?

          super(keeper_id: keeper_id, enclosure_id: enclosure_id, amount: amount)
        end
      end
    end
  end
end
