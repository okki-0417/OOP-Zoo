# frozen_string_literal: true

module Zoo
  module Domain
    class Assignment
      include Shared::Entity

      attr_reader :id, :keeper, :enclosure, :occurred_on

      def initialize(keeper:, enclosure:, relieved: false, occurred_on: 0, id: Shared::Identifier.new)
        @id = id
        @keeper = keeper
        @enclosure = enclosure
        @relieved = relieved
        @occurred_on = occurred_on
        freeze
      end

      def keeper_id
        @keeper.id
      end

      def enclosure_id
        @enclosure.id
      end

      def active?
        !@relieved
      end

      def relieved?
        @relieved
      end

      def relieve
        self.class.new(
          keeper: @keeper, enclosure: @enclosure, relieved: true, occurred_on: @occurred_on, id: @id
        )
      end

      def to_s
        "#{@keeper.name}を#{@enclosure.name}に配属"
      end
    end
  end
end
