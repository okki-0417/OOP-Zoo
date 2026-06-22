# frozen_string_literal: true

module Zoo
  module Domain
    class Relieving
      include Shared::Entity

      attr_reader :id, :tending, :occurred_on

      def self.of(tending, occurred_on: 0, id: Shared::Identifier.new)
        new(tending: tending, occurred_on: occurred_on, id: id)
      end

      def initialize(tending:, occurred_on: 0, id: Shared::Identifier.new)
        @id = id
        @tending = tending
        @occurred_on = occurred_on
        freeze
      end

      def keeper
        @tending.keeper
      end

      def enclosure
        @tending.enclosure
      end

      def keeper_id
        @tending.keeper_id
      end

      def enclosure_id
        @tending.enclosure_id
      end

      def to_s
        "#{keeper.name}を#{enclosure.name}の担当から外す"
      end
    end
  end
end
