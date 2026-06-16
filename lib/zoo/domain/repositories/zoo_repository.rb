# frozen_string_literal: true

module Zoo
  module Domain
    module Repositories
      module ZooRepository
        def load
          raise NotImplementedError, "#{self.class}#load を実装してください"
        end

        def save(_zoo)
          raise NotImplementedError, "#{self.class}#save を実装してください"
        end
      end
    end
  end
end
