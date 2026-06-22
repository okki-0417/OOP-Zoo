# frozen_string_literal: true

module Zoo
  module Domain
    class Assignment
      attr_reader :enclosure, :assignees

      def initialize(enclosure, assignees = [])
        @enclosure = enclosure
        @assignees = assignees
      end
    end
  end
end
