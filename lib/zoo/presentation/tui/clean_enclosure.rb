# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class CleanEnclosure < Action
        def call
          keeper_id = choose_keeper or return @output.puts('飼育員がいません')
          enclosure_id = choose_enclosure or return @output.puts('エリアがありません')
          amount = @prompt.ask('清掃量(空Enterで100):', convert: :int, default: 100)

          enclosure = @container.clean_enclosure.call(
            Application::Commands::CleanEnclosureCommand.new(
              keeper_id: keeper_id, enclosure_id: enclosure_id, amount: amount
            )
          )
          @output.puts "清掃しました: #{enclosure.name}（清潔度 #{enclosure.cleanliness.level}）"
        end
      end
    end
  end
end
