# frozen_string_literal: true

module Zoo
  module Presentation
    module Renderers
      module Passthrough
        module_function

        def render(result)
          result
        end
      end
    end
  end
end
