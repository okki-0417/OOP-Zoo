# frozen_string_literal: true

module Zoo
  module Domain
    class Tending
      include Shared::Entity

      attr_reader :id, :keeper, :enclosure, :occurred_on

      def initialize(keeper:, enclosure:, occupants: [], keepers: [], occurred_on: 0, id: Shared::Identifier.new)
        @id = id
        @keeper = keeper
        @enclosure = enclosure
        @occupants = occupants
        @keepers = keepers
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
        if already_tending?
          raise Errors::TendingNotAllowed,
                "飼育員#{@keeper.name}はすでに#{@enclosure.name}を担当しています"
        end

        unqualified = @occupants.map(&:taxon_class).uniq.reject { |taxon| @keeper.specialized_in?(taxon) }
        return if unqualified.empty?

        raise Errors::TendingNotAllowed,
              "飼育員#{@keeper.name}は#{@enclosure.name}にいる#{unqualified.map(&:label).join('・')}を担当できません"
      end

      def to_s
        "#{@keeper.name}を#{@enclosure.name}に配属"
      end

      private

      def already_tending?
        @keepers.any? { |keeper| keeper.id.to_s == @keeper.id.to_s }
      end
    end
  end
end
