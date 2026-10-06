# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      module Entity
        def ==(other)
          other.is_a?(self.class) && id == other.id
        end
        alias eql? ==

        def hash
          [self.class, id].hash
        end
      end
    end
  end
end
