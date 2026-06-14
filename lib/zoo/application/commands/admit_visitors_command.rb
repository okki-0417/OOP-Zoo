# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      AdmitVisitorsCommand = Data.define(:count) do
        def initialize(count:)
          raise ArgumentError, 'count は必須です' if count.nil?

          super(count: count)
        end
      end
    end
  end
end
