# frozen_string_literal: true

module Zoo
  module Domain
    module Repositories
      module AssignmentRepository
        def save(_event)
          raise NotImplementedError, "#{self.class}#save を実装してください"
        end

        def all
          raise NotImplementedError, "#{self.class}#all を実装してください"
        end

        def enclosures_of(_keeper)
          raise NotImplementedError, "#{self.class}#enclosures_of を実装してください"
        end

        def active_assignment_of(_keeper, _enclosure)
          raise NotImplementedError, "#{self.class}#active_assignment_of を実装してください"
        end

        def keepers_of(_enclosure)
          raise NotImplementedError, "#{self.class}#keepers_of を実装してください"
        end
      end
    end
  end
end
