# frozen_string_literal: true

module Services
  module Commands
    TransferAnimalCommand = Data.define(:animal_id, :enclosure_id) do
      def initialize(animal_id:, enclosure_id:)
        raise ArgumentError, 'animal_id は必須です' if animal_id.nil?
        raise ArgumentError, 'enclosure_id は必須です' if enclosure_id.nil?

        super
      end
    end
  end
end
