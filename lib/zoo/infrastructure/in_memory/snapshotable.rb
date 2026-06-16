# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      module Snapshotable
        def snapshot
          @store.dup
        end

        def restore(snapshot)
          @store = snapshot
        end
      end
    end
  end
end
