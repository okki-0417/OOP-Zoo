# frozen_string_literal: true

module Zoo
  module Domain
    class Relieving
      include Shared::Entity

      attr_reader :id, :tending, :occurred_on

      def self.of(tending, assignment: nil, occurred_on: 0, id: Shared::Identifier.new)
        new(tending: tending, assignment: assignment, occurred_on: occurred_on, id: id)
      end

      def initialize(tending:, assignment: nil, occurred_on: 0, id: Shared::Identifier.new)
        @id = id
        @tending = tending
        @assignment = assignment
        @occurred_on = occurred_on
        freeze
      end

      def violation!
        return if @assignment&.assigned?(@tending.keeper_id)

        raise Errors::ReliefNotAllowed,
              "飼育員#{@tending.keeper_name}は#{@tending.enclosure_name}を担当していないため退任できません"
      end

      def to_s
        "#{@tending.keeper_name}を#{@tending.enclosure_name}の担当から外す"
      end
    end
  end
end
