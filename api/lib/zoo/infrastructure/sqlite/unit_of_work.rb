# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class UnitOfWork
        include Application::UnitOfWork

        def initialize(database)
          @database = database
        end

        def run(&block)
          return block.call if @database.transaction_active?

          @database.transaction(&block)
        end
      end
    end
  end
end
