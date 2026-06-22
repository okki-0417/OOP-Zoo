# frozen_string_literal: true

module Zoo
  module Domain
    class Tending
      include Shared::Entity

      attr_reader :id, :keeper, :enclosure, :occurred_on

      def initialize(keeper:, enclosure:, occupancy: nil, assignment: nil, occurred_on: 0, id: Shared::Identifier.new)
        @id = id
        @keeper = keeper
        @enclosure = enclosure
        @occupancy = occupancy
        @assignment = assignment
        @occurred_on = occurred_on
        freeze
      end

      def keeper_id
        @keeper.id
      end

      def enclosure_id
        @enclosure.id
      end

      def violation!
        if already_assigned?
          raise Errors::AssignmentNotAllowed,
                "飼育員#{@keeper.name}はすでに#{@enclosure.name}を担当しています"
        end

        unqualified = occupant_taxa.reject { |taxon| @keeper.specialized_in?(taxon) }
        return if unqualified.empty?

        raise Errors::AssignmentNotAllowed,
              "飼育員#{@keeper.name}は#{@enclosure.name}にいる#{unqualified.map(&:label).join('・')}を担当できません"
      end

      def to_s
        "#{@keeper.name}を#{@enclosure.name}に配属"
      end

      private

      def already_assigned?
        return false if @assignment.nil?

        @assignment.assignees.any? { |assignee| assignee.id.to_s == @keeper.id.to_s }
      end

      def occupant_taxa
        return [] if @occupancy.nil?

        @occupancy.species_present_in.map(&:taxon_class).uniq
      end
    end
  end
end
