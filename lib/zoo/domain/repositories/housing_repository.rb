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

        def events_for_enclosure(_enclosure_id)
          raise NotImplementedError, "#{self.class}#events_for_enclosure を実装してください"
        end

        def current_housing_of(_animal)
          raise NotImplementedError, "#{self.class}#current_housing_of を実装してください"
        end

        def occupants_of(_enclosure)
          raise NotImplementedError, "#{self.class}#occupants_of を実装してください"
        end

        def all_occupants
          raise NotImplementedError, "#{self.class}#all_occupants を実装してください"
        end
      end
    end
  end
end
