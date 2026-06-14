# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class SaveGame < Action
        def call
          @container.save(Tui::SAVE_PATH)
          @output.puts "セーブしました（#{Tui::SAVE_PATH}）"
        end
      end
    end
  end
end
