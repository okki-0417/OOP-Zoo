# frozen_string_literal: true

module Services
  module Commands
    HireVeterinarianCommand = Data.define(:name) do
      def initialize(name:)
        raise ArgumentError, 'name は必須です' if name.nil?

        super
      end
    end
  end
end
