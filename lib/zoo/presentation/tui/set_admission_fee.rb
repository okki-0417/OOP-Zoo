# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class SetAdmissionFee < Action
        def call
          yen = @prompt.ask('新しい入園料(円):', convert: :int)

          fee = @container.set_admission_fee.call(
            Application::Commands::SetAdmissionFeeCommand.new(fee: Domain::Shared::Money.yen(yen))
          )
          @output.puts "入園料を改定しました: #{fee}（高いほど客単価↑・来園者↓）"
        end
      end
    end
  end
end
