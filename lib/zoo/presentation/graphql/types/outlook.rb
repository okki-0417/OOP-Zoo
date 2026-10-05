# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
      module Types
        class Outlook < GraphQL::Schema::Enum
          %i[good guarded grave].each { |outlook| value outlook.to_s.upcase, value: outlook }
        end
      end
    end
  end
end
