# frozen_string_literal: true

module Zoo
  module Presentation
    # 駆動アダプタのルーター。コマンド名をハンドラに配送し、例外をユーザ向け
    # メッセージと終了コード(0/1)に翻訳する。各コマンドの処理は Cli::* に1クラスずつ
    # 置くため、コマンド追加は「ファイルを足して handlers に1行」で済む。
    class Cli
      def initialize(container:, output: $stdout)
        @container = container
        @output = output
      end

      def run(argv)
        name, *args = argv
        handler = handlers[name]
        unless handler
          @output.puts "未知のコマンド: #{name}"
          return 1
        end

        handler.new(container: @container, output: @output).run(args)
        0
      rescue Application::Errors::ApplicationError, Domain::Errors::DomainError, ArgumentError => e
        @output.puts "エラー: #{e.message}"
        1
      end

      private

      def handlers
        {
          'acquire' => Acquire,
          'build-enclosure' => BuildEnclosure,
          'house' => House,
          'hire-keeper' => HireKeeper,
          'hire-veterinarian' => HireVeterinarian,
          'feed' => Feed,
          'treat' => Treat,
          'clean' => Clean,
          'breed' => Breed,
          'transfer' => Transfer,
          'examine' => Examine,
          'admit-visitors' => AdmitVisitors,
          'population' => Population,
          'threatened' => Threatened,
          'revenue' => Revenue,
          'enclosures' => Enclosures,
          'enclosure' => Enclosure,
          'animals' => Animals,
          'animal' => Animal,
          'rename' => Rename,
          'release' => Release,
          'set-fee' => SetFee,
          'deceased' => Deceased,
          'report' => Report,
          'open' => Open,
          'run-days' => RunDays,
          'operate' => Operate
        }
      end
    end
  end
end
