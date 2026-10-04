# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      TaxonClassListCommand = Data.define do
        def bind(**)
          self
        end
      end
    end
  end
end
