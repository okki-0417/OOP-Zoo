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

      def keeper_name
        @keeper.name
      end

      def enclosure_name
        @enclosure.name
      end

      def violation!
        errors = []
        if @assignment&.assigned?(@keeper.id)
          errors << "飼育員#{keeper_name}はすでに#{enclosure_name}を担当しています"
        end

        unqualified = occupant_taxa.reject { |taxon| @keeper.specialized_in?(taxon) }
        unless unqualified.empty?
          errors << "飼育員#{keeper_name}は#{enclosure_name}にいる#{unqualified.map(&:label).join('・')}を担当できません"
        end

        raise Errors::AssignmentNotAllowed, errors.join(', ') unless errors.empty?
      end

      def to_s
        "#{keeper_name}を#{enclosure_name}に配属"
      end

      private

      def occupant_taxa
        return [] if @occupancy.nil?

        @occupancy.species_present_in.map(&:taxon_class).uniq
      end
    end
  end
end
