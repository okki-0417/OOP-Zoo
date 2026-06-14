# frozen_string_literal: true

require 'tty-prompt'
require 'tty-cursor'

module Zoo
  module Presentation
    class Tui
      SAVE_PATH = 'tmp/zoo.save'

      def initialize(container:, prompt: TTY::Prompt.new, output: $stdout, view: View.new)
        @container = container
        @prompt = prompt
        @output = output
        @view = view
      end

      def run
        items = menu
        loop do
          clear
          @output.puts @view.dashboard(@container.zoo_report.call, enclosures: enclosure_count, staff: staff_count)
          label = @prompt.select('▶ 操作を選択', items.keys, per_page: items.size, cycle: true, filter: true)
          action_class = items[label]
          break if action_class == :quit

          @output.puts @view.section(label)
          dispatch(action_class)
          @prompt.keypress(@view.continue_hint)
        end
      end

      def dispatch(action_class)
        action_class.new(container: @container, prompt: @prompt, output: @output, view: @view).call
      rescue Application::Errors::ApplicationError, Domain::Errors::DomainError, ArgumentError => e
        @output.puts @view.error(e.message)
      end

      private

      def clear
        @output.print(TTY::Cursor.clear_screen, TTY::Cursor.move_to(0, 0))
      end

      def enclosure_count
        @container.enclosure_list.call.size
      end

      def staff_count
        @container.keeper_list.call.size + @container.veterinarian_list.call.size
      end

      private

      def menu
        {
          '個体一覧' => ListAnimals,
          '個体の詳細' => ShowAnimal,
          'エリア一覧' => ListEnclosures,
          'エリアの詳細' => ShowEnclosure,
          '絶滅危惧種' => ThreatenedSpecies,
          '慰霊記録' => Deceased,
          'レポート' => Report,
          '個体を受け入れる' => AcquireAnimal,
          'エリアを作る' => BuildEnclosure,
          '飼育員を採用' => HireKeeper,
          '獣医を採用' => HireVeterinarian,
          '収容する' => HouseAnimal,
          '移送する' => TransferAnimal,
          '展示から外す' => ReleaseAnimal,
          '改名する' => RenameAnimal,
          '給餌する' => FeedAnimal,
          '治療する' => TreatAnimal,
          '診察する' => ExamineAnimal,
          '清掃する' => CleanEnclosure,
          '繁殖させる' => BreedAnimals,
          '来園者を受け入れる' => AdmitVisitors,
          '入園料を改定' => SetAdmissionFee,
          '1日運営する' => OperateDay,
          '複数日進める' => RunDays,
          'セーブする' => SaveGame,
          '終了' => :quit
        }
      end
    end
  end
end
