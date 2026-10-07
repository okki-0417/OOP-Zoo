# frozen_string_literal: true

module Types
  class Outlook < GraphQL::Schema::Enum
    %i[good guarded grave].each { |outlook| value outlook.to_s.upcase, value: outlook }
  end
end
