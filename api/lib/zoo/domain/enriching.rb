# frozen_string_literal: true

module Zoo
  module Domain
    class Enriching
      WORK_MINUTES = 30

      def initialize(keeper:, enclosure:)
        @keeper = keeper
        @enclosure = enclosure
      end

      def perform
        @keeper.clock_in(WORK_MINUTES)
        @enclosure.enrich
      end

      def to_s
        "#{@keeper.name}が#{@enclosure.name}に遊具を補充"
      end
    end
  end
end
