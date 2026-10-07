# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      OperateDayCommand = Data.define(:random) do
        def initialize(random: Random.new)
          super
        end
      end
    end
  end
end
