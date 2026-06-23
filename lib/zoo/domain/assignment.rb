# frozen_string_literal: true

module Zoo
  module Domain
    class Assignment
      def initialize(enclosure, assignees = [])
        @enclosure = enclosure
        @assignees = assignees
      end

      def assigned?(keeper_id)
        @assignees.any? { |assignee| assignee.id.to_s == keeper_id.to_s }
      end
    end
  end
end
