# frozen_string_literal: true

module Zoo
  module Domain
    class EnclosureDischarge
      include Shared::Entity

      attr_reader :id, :assignment, :occurred_on

      def self.of(assignment, occurred_on: 0, id: Shared::Identifier.new)
        new(assignment: assignment, occurred_on: occurred_on, id: id)
      end

      def initialize(assignment:, occurred_on: 0, id: Shared::Identifier.new)
        @id = id
        @assignment = assignment
        @occurred_on = occurred_on
        freeze
      end

      def keeper
        @assignment.keeper
      end

      def enclosure
        @assignment.enclosure
      end

      def keeper_id
        @assignment.keeper_id
      end

      def enclosure_id
        @assignment.enclosure_id
      end

      def to_s
        "#{keeper.name}を#{enclosure.name}の担当から外す"
      end
    end
  end
end
