# frozen_string_literal: true

module Zoo
  module Domain
    class Housing
      include Shared::Entity

      attr_reader :id, :animal, :enclosure_id, :occurred_on, :keeper_id

      def self.record(animal:, enclosure:, occurred_on: 0, keeper_id: nil, id: Shared::Identifier.new)
        new(animal: animal, enclosure_id: enclosure.id, occurred_on: occurred_on, keeper_id: keeper_id, id: id)
      end

      def initialize(animal:, enclosure_id:, occurred_on: 0, keeper_id: nil, id: Shared::Identifier.new)
        @id = id
        @animal = animal
        @enclosure_id = enclosure_id
        @occurred_on = occurred_on
        @keeper_id = keeper_id
        freeze
      end

      def to_s
        "#{@animal.name}を収容"
      end
    end
  end
end
