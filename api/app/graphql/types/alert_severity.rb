# frozen_string_literal: true

module Types
  class AlertSeverity < GraphQL::Schema::Enum
    Services::AlertList::SEVERITIES.each { |severity| value severity.to_s.upcase, value: severity }
  end
end
