# frozen_string_literal: true

module Zoo
  module Domain
    class Tending
      def initialize(keeper:, enclosure:, occupants: [], keepers: [])
        @keeper = keeper
        @enclosure = enclosure
        @occupants = occupants
        @keepers = keepers
        freeze
      end

      def violation!
        if already_assigned?
          raise Errors::AssignmentNotAllowed,
                "飼育員#{@keeper.name}はすでに#{@enclosure.name}を担当しています"
        end

        unqualified = @occupants.map(&:taxon_class).uniq.reject { |taxon| @keeper.specialized_in?(taxon) }
        return if unqualified.empty?

        raise Errors::AssignmentNotAllowed,
              "飼育員#{@keeper.name}は#{@enclosure.name}にいる#{unqualified.map(&:label).join('・')}を担当できません"
      end

      def assign
        Assignment.new(keeper: @keeper, enclosure: @enclosure)
      end

      private

      def already_assigned?
        @keepers.any? { |keeper| keeper.id.to_s == @keeper.id.to_s }
      end
    end
  end
end
