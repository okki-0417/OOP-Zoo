# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      SetAdmissionFeeCommand = Data.define(:fee) do
        def initialize(fee:)
          raise ArgumentError, 'fee は必須です' if fee.nil?

          super
        end
      end
    end
  end
end
