# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class Action
        def initialize(container:, prompt:, output:, view:)
          @container = container
          @prompt = prompt
          @output = output
          @view = view
        end

        def call
          raise NotImplementedError, "#{self.class}#call を実装してください"
        end

        protected

        def choose_animal(message = '個体を選択')
          choose(message, @container.animal_list.call) { |row| "#{row.name}（#{row.species}）" }
        end

        def choose_enclosure(message = 'エリアを選択')
          choose(message, @container.enclosure_list.call) { |row| "#{row.name}（#{row.population}/#{row.capacity}）" }
        end

        def choose_keeper(message = '飼育員を選択')
          choose(message, @container.keeper_list.call) { |row| "#{row.name}（#{row.specialties}）" }
        end

        def choose_veterinarian(message = '獣医を選択')
          choose(message, @container.veterinarian_list.call, &:name)
        end

        def choose(message, rows)
          return nil if rows.empty?

          @prompt.select(message, rows.to_h { |row| [yield(row), row.id] })
        end
      end
    end
  end
end
