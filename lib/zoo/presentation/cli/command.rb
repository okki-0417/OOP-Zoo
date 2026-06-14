# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Command
        def initialize(container:, output:)
          @container = container
          @output = output
        end

        def run(_args)
          raise NotImplementedError, "#{self.class}#run を実装してください"
        end
      end
    end
  end
end
