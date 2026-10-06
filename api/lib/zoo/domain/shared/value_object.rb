# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      module ValueObject
        def ==(other)
          other.is_a?(self.class) && components == other.components
        end
        alias eql? ==

        def hash
          [self.class, *components].hash
        end

        def freeze
          components.each { |c| c.freeze if c.respond_to?(:freeze) }
          super
        end

        protected

        def components
          raise NotImplementedError, "#{self.class}は#componentsを実装する必要があります"
        end
      end
    end
  end
end
