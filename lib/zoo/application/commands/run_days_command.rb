# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      RunDaysCommand = Data.define(:days) do
        def initialize(days:)
          raise ArgumentError, 'days は必須です' if days.nil?
          raise ArgumentError, 'days は1以上でなければなりません' unless days.is_a?(Integer) && days.positive?

          super
        end
      end
    end
  end
end
