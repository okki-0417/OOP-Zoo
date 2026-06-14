# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      # TUI アクションの基底。container・prompt・output・view を受け取り call で処理する。
      # 対象(個体・エリア・飼育員)は choose_* でリスト選択させ、id の手入力を不要にする。
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

        # 行が無ければ nil(呼び手が中断)。あれば「ラベル→id」で選択させ id を返す。
        def choose(message, rows)
          return nil if rows.empty?

          @prompt.select(message, rows.to_h { |row| [yield(row), row.id] })
        end
      end
    end
  end
end
