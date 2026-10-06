# frozen_string_literal: true

module Zoo
  module Domain
    module Repositories
      module KeeperRepository
        def find(_id)
          raise NotImplementedError, "#{self.class}#find を実装してください"
        end

        def save(_keeper)
          raise NotImplementedError, "#{self.class}#save を実装してください"
        end

        def all
          raise NotImplementedError, "#{self.class}#all を実装してください"
        end
      end
    end
  end
end
