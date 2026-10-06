# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class AlertSeverity < GraphQL::Schema::Enum
          Application::Services::AlertList::SEVERITIES.each { |severity| value severity.to_s.upcase, value: severity }
        end
      end
    end
  end
end
