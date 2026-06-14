# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class ShowEnclosure < Action
        def call
          enclosure_id = choose_enclosure or return @output.puts('エリアがありません')

          @output.puts @view.enclosure_detail(@container.enclosure_detail.call(enclosure_id))
        end
      end
    end
  end
end
