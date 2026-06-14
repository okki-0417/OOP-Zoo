# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      EnclosureSummary = Data.define(:id, :name, :population, :capacity, :cleanliness, :filthy)
    end
  end
end
