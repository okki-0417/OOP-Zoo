# frozen_string_literal: true

require 'monitor'

module Zoo
  module Infrastructure
    module InMemory
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
