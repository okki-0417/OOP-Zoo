# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class SetAdmissionFee < Action
        def call(params)
          fee = @container.set_admission_fee.call(
            Application::Commands::SetAdmissionFeeCommand.new(fee: Domain::Shared::Money.yen(Integer(params['fee'])))
          )
          [200, { admission_fee: fee.yen }]
        end
      end
    end
  end
end
