# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      EnclosureDetailCommand = Data.define(:enclosure_id, :enclosures, :housings) do
        def initialize(enclosure_id:, enclosures: nil, housings: nil)
          raise ArgumentError, 'enclosure_id は必須です' if enclosure_id.nil?

          super
        end

        def bind(enclosures:, housings:, **)
          with(enclosures:, housings:)
        end
      end
    end
  end
end
