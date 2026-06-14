# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      KeeperSummary = Data.define(:id, :name, :specialties)
    end
  end
end
