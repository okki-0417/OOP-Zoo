# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      HireVeterinarianCommand = Data.define(:name, :veterinarians, :zoo, :unit_of_work) do
        def initialize(name:, veterinarians: nil, zoo: nil, unit_of_work: nil)
          raise ArgumentError, 'name は必須です' if name.nil?

          super
        end

        def bind(veterinarians:, zoo:, unit_of_work:, **)
          with(veterinarians:, zoo:, unit_of_work:)
        end
      end
    end
  end
end
