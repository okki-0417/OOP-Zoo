# frozen_string_literal: true

module Types
  class Sex < GraphQL::Schema::Enum
    ::Animal::Sex::VALUES.each_key { |sex| value sex.to_s.upcase, value: sex }
  end
end
