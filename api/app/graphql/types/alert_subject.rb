# frozen_string_literal: true

module Types
  class AlertSubject < GraphQL::Schema::Enum
    %i[zoo enclosure animal].each { |type| value type.to_s.upcase, value: type }
  end
end
