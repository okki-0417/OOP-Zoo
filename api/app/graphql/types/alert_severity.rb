# frozen_string_literal: true

module Types
  class AlertSeverity < GraphQL::Schema::Enum
    ::Alert::SEVERITIES.each { |severity| value severity.to_s.upcase, value: severity }
  end
end
