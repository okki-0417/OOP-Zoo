# frozen_string_literal: true

module Zoo
  module Domain
    module Repositories
      # 動物園は単一の集約なので id ではなく load/save で出し入れする。
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
