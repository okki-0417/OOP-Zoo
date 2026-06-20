# frozen_string_literal: true

module Zoo
  module Domain
    module Repositories
      module BirthRepository
        def save(_birth)
          raise NotImplementedError, "#{self.class}#save を実装してください"
        end

        def all
          raise NotImplementedError, "#{self.class}#all を実装してください"
        end

        def ancestry(*_animals, max_depth: nil)
          raise NotImplementedError, "#{self.class}#ancestry を実装してください"
        end
      end
    end
  end
end
