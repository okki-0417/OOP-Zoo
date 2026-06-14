# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      DeceasedRecord = Data.define(:name, :species, :cause)
    end
  end
end
