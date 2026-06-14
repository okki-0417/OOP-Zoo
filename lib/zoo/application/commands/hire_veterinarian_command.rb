# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      HireVeterinarianCommand = Data.define(:name) do
        def initialize(name:)
          raise ArgumentError, 'name は必須です' if name.nil?

          super(name: name)
        end
      end
    end
  end
end
