# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class SetFee < Command
        def run(args)
          yen, = args
          raise ArgumentError, '使い方: set-fee YEN' if yen.nil?

          fee = @container.set_admission_fee.call(
            Application::Commands::SetAdmissionFeeCommand.new(fee: Domain::Shared::Money.yen(Integer(yen)))
          )
          @output.puts "入園料を改定しました: #{fee}"
        end
      end
    end
  end
end
