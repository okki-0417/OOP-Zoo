# frozen_string_literal: true

module Zoo
  module Domain
    module Repositories
      module AnimalRepository
        def find(_id)
          raise NotImplementedError, "#{self.class}#find を実装してください"
        end

        def find_all(_ids)
          raise NotImplementedError, "#{self.class}#find_all を実装してください"
        end

        def save(_animal)
          raise NotImplementedError, "#{self.class}#save を実装してください"
        end
      end
    end
  end
end
