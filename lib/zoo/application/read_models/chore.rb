# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      Chore = Data.define(:kind, :label, :items) do
        def done_count
          items.count(&:done)
        end

        def total
          items.size
        end

        def done?
          done_count == total
        end
      end
    end
  end
end
