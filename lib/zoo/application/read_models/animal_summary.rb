# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      AnimalSummary = Data.define(:id, :name, :species, :alive, :health, :max_health, :ailing)
    end
  end
end
