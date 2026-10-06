# frozen_string_literal: true

module Zoo
  module Domain
    module Repositories
      module BreedingRepository
        def save(_breeding)
          raise NotImplementedError, "#{self.class}#save を実装してください"
        end

        def for_dam(_dam_id)
          raise NotImplementedError, "#{self.class}#for_dam を実装してください"
        end
      end
    end
  end
end
