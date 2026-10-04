# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      ExaminationReport = Data.define(:animal_id, :diagnosis)
    end
  end
end
