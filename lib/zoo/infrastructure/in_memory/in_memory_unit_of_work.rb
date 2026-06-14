# frozen_string_literal: true

require 'monitor'

module Zoo
  module Infrastructure
    module InMemory
      # ユースケースを総ロックで直列化し(isolation)、登録リポジトリのスナップショットで
      # 例外時に巻き戻す(atomicity)。書き込みを伴うリポジトリだけ repositories に渡す。
      class InMemoryUnitOfWork
        include Application::UnitOfWork

        def initialize(repositories: [])
          @repositories = repositories
          @monitor = Monitor.new
        end

        def run
          @monitor.synchronize do
            snapshots = @repositories.map { |repo| [repo, repo.snapshot] }
            begin
              yield
            rescue StandardError
              snapshots.each { |repo, snapshot| repo.restore(snapshot) }
              raise
            end
          end
        end
      end
    end
  end
end
