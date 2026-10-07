# frozen_string_literal: true

module Services
  module Commands
    RunDaysCommand = Data.define(:days, :random) do
      def initialize(days:, random: Random.new)
        raise ArgumentError, 'days は必須です' if days.nil?
        raise ArgumentError, 'days は1以上でなければなりません' unless days.is_a?(Integer) && days.positive?

        super
      end

      def operate_day_command
        OperateDayCommand.new(random:)
      end
    end
  end
end
