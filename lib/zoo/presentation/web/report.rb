# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class Report < Action
        def call(_params)
          [200, Serializer.zoo_statistics(@container.zoo_report.call)]
        end
      end
    end
  end
end
