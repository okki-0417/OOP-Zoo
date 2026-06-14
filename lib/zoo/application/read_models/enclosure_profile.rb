# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      EnclosureProfile = Data.define(:id, :name, :capacity, :population, :cleanliness, :filthy, :occupants)
    end
  end
end
