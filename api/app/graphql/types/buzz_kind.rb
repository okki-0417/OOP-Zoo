# frozen_string_literal: true

module Types
  class BuzzKind < GraphQL::Schema::Enum
    %i[newborn newcomer].each { |kind| value kind.to_s.upcase, value: kind }
  end
end
