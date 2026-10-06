# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      AdmitVisitorsCommand = Data.define(:count, :zoo, :unit_of_work) do
        def initialize(count:, zoo: nil, unit_of_work: nil)
          raise ArgumentError, 'count は必須です' if count.nil?

          super
        end

        def bind(zoo:, unit_of_work:, **)
          with(zoo:, unit_of_work:)
        end
      end
    end
  end
end
