# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      VeterinarianSummary = Data.define(:id, :name) do
        def self.of(veterinarian)
          new(id: veterinarian.id.to_s, name: veterinarian.name)
        end
      end
    end
  end
end
