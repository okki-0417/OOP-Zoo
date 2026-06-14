# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Enclosure < Command
        def run(args)
          enclosure_id, = args
          raise ArgumentError, '使い方: enclosure ENCLOSURE_ID' if enclosure_id.nil?

          profile = @container.enclosure_detail.call(enclosure_id)
          raise Application::Errors::EnclosureNotFound, "エリア #{enclosure_id} は存在しません" if profile.nil?

          @output.puts "#{profile.name}（#{profile.population}/#{profile.capacity}）" \
                       "清潔度 #{profile.cleanliness}#{profile.filthy ? ' ⚠不衛生' : ''}"
          profile.occupants.each { |o| @output.puts "  - #{o.name}（#{o.species}）" }
        end
      end
    end
  end
end
