# frozen_string_literal: true

module Zoo
  module Domain
    module Repositories
      module FoodRepository
        def find(_code)
          raise NotImplementedError, "#{self.class}#find を実装してください"
        end

        def all_by_code
          raise NotImplementedError, "#{self.class}#all_by_code を実装してください"
        end
      end
    end
  end
end
