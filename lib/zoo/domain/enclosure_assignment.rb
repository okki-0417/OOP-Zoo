# frozen_string_literal: true

module Zoo
  module Domain
    class EnclosureAssignment
      include Shared::Entity

      attr_reader :id, :keeper, :enclosure, :occurred_on

      def initialize(keeper:, enclosure:, occupants: [], occurred_on: 0, id: Shared::Identifier.new)
        @id = id
        @keeper = keeper
        @enclosure = enclosure
        @occupants = occupants
        @occurred_on = occurred_on
        freeze
      end

      def keeper_id
        @keeper.id
      end

      def enclosure_id
        @enclosure.id
      end

      def assignment_violation!
        unqualified = @occupants.map(&:taxon_class).uniq.reject { |taxon| @keeper.specialized_in?(taxon) }
        return if unqualified.empty?

        raise Errors::EnclosureAssignmentNotAllowed,
              "飼育員#{@keeper.name}は#{@enclosure.name}にいる#{unqualified.map(&:label).join('・')}を担当できません"
      end

      def to_s
        "#{@keeper.name}を#{@enclosure.name}に配属"
      end
    end
  end
end
