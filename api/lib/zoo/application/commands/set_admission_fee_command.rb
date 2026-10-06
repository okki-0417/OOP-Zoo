# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      SetAdmissionFeeCommand = Data.define(:fee, :zoo, :unit_of_work) do
        def initialize(fee:, zoo: nil, unit_of_work: nil)
          raise ArgumentError, 'fee は必須です' if fee.nil?

          super
        end

        def bind(zoo:, unit_of_work:, **)
          with(zoo:, unit_of_work:)
        end
      end
    end
  end
end
