# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      ExhibitedSpecies = Data.define(:name_ja, :status_code, :status_label, :count)
    end
  end
end
