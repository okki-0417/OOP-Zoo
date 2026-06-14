# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      EnclosureSummary = Data.define(:id, :name, :population, :capacity)
    end
  end
end
