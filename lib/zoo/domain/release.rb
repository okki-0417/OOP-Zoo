# frozen_string_literal: true

module Zoo
  module Domain
    class Release
      include Shared::Entity

      attr_reader :id, :housing, :occurred_on, :keeper_id

      def self.of(housing, occurred_on: 0, keeper_id: nil, id: Shared::Identifier.new)
        new(housing: housing, occurred_on: occurred_on, keeper_id: keeper_id, id: id)
      end

      def initialize(housing:, occurred_on: 0, keeper_id: nil, id: Shared::Identifier.new)
        @id = id
        @housing = housing
        @occurred_on = occurred_on
        @keeper_id = keeper_id
        freeze
      end

      def animal
        @housing.animal
      end

      def enclosure
        @housing.enclosure
      end

      def enclosure_id
        @housing.enclosure_id
      end

      def to_s
        "#{animal.name}を解放"
      end
    end
  end
end
