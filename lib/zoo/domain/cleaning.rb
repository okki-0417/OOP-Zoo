# frozen_string_literal: true

module Zoo
  module Domain
    class Cleaning
      include Shared::Entity

      attr_reader :id, :keeper, :enclosure, :occurred_on

      def initialize(keeper:, enclosure:, amount: 100, occurred_on: 0, id: Shared::Identifier.new)
        @id = id
        @keeper = keeper
        @enclosure = enclosure
        @amount = amount
        @occurred_on = occurred_on
        freeze
      end

      def keeper_id
        @keeper.id
      end

      def enclosure_id
        @enclosure.id
      end

      def perform
        @enclosure.clean(@amount)
      end

      def to_s
        "#{@keeper.name}が#{@enclosure.name}を清掃"
      end
    end
  end
end
