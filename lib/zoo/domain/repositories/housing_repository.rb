# frozen_string_literal: true

module Zoo
  module Domain
    module Repositories
      module HousingRepository
        def save(_housing)
          raise NotImplementedError, "#{self.class}#save を実装してください"
        end

        def all
          raise NotImplementedError, "#{self.class}#all を実装してください"
        end
      end
    end
  end
end
