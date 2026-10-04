# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      VeterinarianListCommand = Data.define(:veterinarians) do
        def initialize(veterinarians: nil)
          super
        end

        def bind(veterinarians:, **)
          with(veterinarians:)
        end
      end
    end
  end
end
