# frozen_string_literal: true

module Services
  module Commands
    NameAnimalCommand = Data.define(:animal_id, :name) do
      def initialize(animal_id:, name:)
        raise ArgumentError, 'animal_id は必須です' if animal_id.nil?
        raise ArgumentError, 'name は必須です' if name.nil?

        super
      end
    end
  end
end
