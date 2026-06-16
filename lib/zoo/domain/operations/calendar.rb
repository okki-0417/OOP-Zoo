# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      module Calendar
        module_function

        DAYS_PER_YEAR = 365
        ORDER = %i[spring summer autumn winter].freeze

        def season_for(elapsed_days)
          index = (elapsed_days % DAYS_PER_YEAR) / (DAYS_PER_YEAR / ORDER.size)
          Season.new(ORDER[index.clamp(0, ORDER.size - 1)])
        end
      end
    end
  end
end
